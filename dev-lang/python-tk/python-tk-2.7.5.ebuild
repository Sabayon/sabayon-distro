# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
WANT_AUTOMAKE="none"
WANT_LIBTOOL="none"

inherit autotools eutils flag-o-matic multilib pax-utils python-utils-r1 toolchain-funcs multiprocessing

MY_P="Python-${PV}"
PATCHSET_REVISION="0"

DESCRIPTION="Tk libraries for Python (also provides IDLE)"
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.xz
	mirror://gentoo/python-gentoo-patches-${PV}-${PATCHSET_REVISION}.tar.xz"

LICENSE="PSF-2"
SLOT="2.7"
PYTHON_ABI="${SLOT}"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="ipv6 +threads +wide-unicode"

RDEPEND="
	=dev-lang/python-${PVR}[-tk]
	ipv6? ( =dev-lang/python-${PVR}[ipv6] )
	threads? ( =dev-lang/python-${PVR}[threads] )
	wide-unicode? ( =dev-lang/python-${PVR}[wide-unicode] )
	>=dev-lang/tk-8.0
	dev-tcltk/blt"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use berkdb; then
		ewarn "'bsddb' module is out-of-date and no longer maintained inside"
		ewarn "dev-lang/python. 'bsddb' and 'dbhash' modules have been additionally"
		ewarn "removed in Python 3. A maintained alternative of 'bsddb3' module"
		ewarn "is provided by dev-python/bsddb3."
	else
		if has_version "=${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"; then
			ewarn "You are migrating from =${CATEGORY}/${PN}-${PV%%.*}*[berkdb]"
			ewarn "to =${CATEGORY}/${PN}-${PV%%.*}*[-berkdb]."
			ewarn "You might need to migrate your databases."
		fi
	fi
}

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat || die
	rm -fr Modules/_ctypes/libffi* || die
	rm -fr Modules/zlib || die

	local excluded_patches
	if ! tc-is-cross-compiler; then
		excluded_patches="*_all_crosscompile.patch"
	fi

	EPATCH_EXCLUDE="${excluded_patches}" EPATCH_SUFFIX="patch" \
		epatch "${WORKDIR}/${PV}-${PATCHSET_REVISION}"

	epatch "${FILESDIR}/${P}-library-path.patch" #474882

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Lib/sysconfig.py \
		Lib/test/test_site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	epatch_user

	eautoconf
	eautoheader
}

src_configure() {
	# Disable extraneous modules with extra dependencies.
	export PYTHON_DISABLE_MODULES="dbm _bsddb gdbm _curses _curses_panel readline _sqlite3 _elementtree pyexpat"
	export PYTHON_DISABLE_SSL="1"

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv

		# The configure script assumes it's buggy when cross-compiling.
		export ac_cv_buggy_getaddrinfo=no
		export ac_cv_have_long_long_format=yes
	fi

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	# Run the configure scripts in parallel.
	multijob_init

	mkdir -p "${WORKDIR}"/{${CBUILD},${CHOST}}

	if tc-is-cross-compiler; then
		(
		multijob_child_init
		cd "${WORKDIR}"/${CBUILD} >/dev/null
		OPT="-O1" CFLAGS="" CPPFLAGS="" LDFLAGS="" CC="" \
		"${S}"/configure \
			--{build,host}=${CBUILD} \
			|| die "cross-configure failed"
		) &
		multijob_post_fork
	fi

	# Export CXX so it ends up in /usr/lib/python2.X/config/Makefile.
	tc-export CXX
	# The configure script fails to use pkg-config correctly.
	# http://bugs.python.org/issue15506
	export ac_cv_path_PKG_CONFIG=$(tc-getPKG_CONFIG)

	# Set LDFLAGS so we link modules with -lpython2.7 correctly.
	# Needed on FreeBSD unless Python 2.7 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	cd "${WORKDIR}"/${CHOST}
	ECONF_SOURCE="${S}" OPT="" \
	econf \
		--with-fpectl \
		--enable-shared \
		$(use_enable ipv6) \
		$(use_with threads) \
		$(use wide-unicode && echo "--enable-unicode=ucs4" || echo "--enable-unicode=ucs2") \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-dbmliborder="${dbmliborder}" \
		--with-libc="" \
		--enable-loadable-sqlite-extensions \
		--with-system-expat \
		--with-system-ffi

	if tc-is-cross-compiler; then
		# Modify the Makefile.pre so we don't regen for the host/ one.
		# We need to link the host python programs into $PWD and run
		# them from here because the distutils sysconfig module will
		# parse Makefile/etc... from argv[0], and we need it to pick
		# up the target settings, not the host ones.
		sed -i \
			-e '1iHOSTPYTHONPATH = ./hostpythonpath:' \
			-e '/^HOSTPYTHON/s:=.*:= ./hostpython:' \
			-e '/^HOSTPGEN/s:=.*:= ./Parser/hostpgen:' \
			Makefile{.pre,} || die "sed failed"
	fi

	multijob_finish
}

src_compile() {
	if tc-is-cross-compiler; then
		cd "${WORKDIR}"/${CBUILD}
		# Disable as many modules as possible -- but we need a few to install.
		PYTHON_DISABLE_MODULES=$(
			sed -n "/Extension('/{s:^.*Extension('::;s:'.*::;p}" "${S}"/setup.py | \
				egrep -v '(unicodedata|time|cStringIO|_struct|binascii)'
		) \
		PTHON_DISABLE_SSL="1" \
		SYSROOT= \
		emake
		# See comment in src_configure about these.
		ln python ../${CHOST}/hostpython || die
		ln Parser/pgen ../${CHOST}/Parser/hostpgen || die
		ln -s ../${CBUILD}/build/lib.*/ ../${CHOST}/hostpythonpath || die
	fi

	cd "${WORKDIR}"/${CHOST}
	default

	# Work around bug 329499. See also bug 413751 and 457194.
	if has_version dev-libs/libffi[pax_kernel]; then
		pax-mark E python
	else
		pax-mark m python
	fi
}

src_install() {
	local libdir=${ED}/usr/$(get_libdir)/python${SLOT}

	cd "${WORKDIR}"/${CHOST}
	emake DESTDIR="${D}" altinstall

	sed -e "s/\(LDFLAGS=\).*/\1/" -i "${libdir}/config/Makefile" || die "sed failed"

        # Fix collisions between different slots of Python.
        mv "${ED}usr/bin/pydoc" "${ED}usr/bin/pydoc${SLOT}"
        mv "${ED}usr/bin/idle" "${ED}usr/bin/idle${SLOT}"

	local myrelfile=""
	for myfile in `find "${ED}"usr/ -type f; find "${ED}"usr/ -type l`; do
		myrelfile="${myfile/${ED}}"
		case "${myrelfile}" in
			*lib-tk*)
				true ;;
			*_tkinter.so)
				true ;;
			*/idlelib/*)
				true ;;
			*bin/idle*)
				true ;;
			*)
				rm "${myfile}" || die ;;
		esac
	done

	# kill empty dirs from ${ED}
	local dropped
	while true; do
		dropped="0"
		for mydir in `find "${ED}"usr/ -type d -empty`; do
			if [ -d "${mydir}" ]; then
				rmdir "${mydir}" || die
				dropped="1"
			fi
		done
		[[ "${dropped}" = "0" ]] && break
	done

	# QA check that we have _tkinter.so
	local found=$(find "${ED}" -name "_tkinter.so")
	[ -z "${found}" ] && die "_tkinter.so not installed"
}
