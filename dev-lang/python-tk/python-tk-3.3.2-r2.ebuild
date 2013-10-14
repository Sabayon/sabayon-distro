# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
WANT_AUTOMAKE="none"
WANT_LIBTOOL="none"

inherit autotools eutils flag-o-matic multilib pax-utils python-utils-r1 toolchain-funcs multiprocessing

MY_P="Python-${PV}"
PATCHSET_REVISION="2"

DESCRIPTION="Tk libraries for Python (also provides IDLE)"
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.xz
	mirror://gentoo/python-gentoo-patches-${PV}-${PATCHSET_REVISION}.tar.xz"

LICENSE="PSF-2"
SLOT="3.3"
PYTHON_ABI="${SLOT}"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="ipv6 +threads"

RDEPEND="
	=dev-lang/python-${PVR}
	ipv6? ( =dev-lang/python-${PVR}[ipv6] )
	threads? ( =dev-lang/python-${PVR}[threads] )
	>=dev-lang/tk-8.0
	dev-tcltk/blt"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat
	rm -fr Modules/_ctypes/libffi*
	rm -fr Modules/zlib

	if tc-is-cross-compiler; then
		# Invokes BUILDPYTHON, which is built for the host arch
		local EPATCH_EXCLUDE="05_all_regenerate_platform-specific_modules.patch"
	fi

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/${PV}-${PATCHSET_REVISION}"
	epatch "${FILESDIR}/python-3.3-CVE-2013-2099.patch"
	epatch "${FILESDIR}/CVE-2013-4238_py33.patch"

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

	# Disable ABI flags.
	sed -e "s/ABIFLAGS=\"\${ABIFLAGS}.*\"/:/" -i configure.ac || die "sed failed"

	epatch_user

	eautoconf
	eautoheader
}

src_configure() {
	# Disable extraneous modules with extra dependencies.
	export PYTHON_DISABLE_MODULES="gdbm _curses _curses_panel readline _sqlite3 _elementtree pyexpat"
	export PYTHON_DISABLE_SSL="1"

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	# Export CXX so it ends up in /usr/lib/python3.X/config/Makefile.
	tc-export CXX
	# The configure script fails to use pkg-config correctly.
	# http://bugs.python.org/issue15506
	export ac_cv_path_PKG_CONFIG=$(tc-getPKG_CONFIG)

	# Set LDFLAGS so we link modules with -lpython3.2 correctly.
	# Needed on FreeBSD unless Python 3.2 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	local dbmliborder
	if use gdbm; then
		dbmliborder+="${dbmliborder:+:}gdbm"
	fi

	BUILD_DIR="${WORKDIR}/${CHOST}"
	mkdir -p "${BUILD_DIR}" || die
	cd "${BUILD_DIR}" || die

	ECONF_SOURCE="${S}" OPT="" \
	econf \
		--with-fpectl \
		--enable-shared \
		$(use_enable ipv6) \
		$(use_with threads) \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-computed-gotos \
		--with-dbmliborder="${dbmliborder}" \
		--with-libc="" \
		--enable-loadable-sqlite-extensions \
		--with-system-expat \
		--with-system-ffi
}

src_compile() {
	# Avoid invoking pgen for cross-compiles.
	touch Include/graminit.h Python/graminit.c || die

	cd "${BUILD_DIR}" || die
	emake CPPFLAGS="" CFLAGS="" LDFLAGS="" || die "emake failed"

	# Work around bug 329499. See also bug 413751 and 457194.
	if has_version dev-libs/libffi[pax_kernel]; then
		pax-mark E python
	else
		pax-mark m python
	fi
}

src_install() {
	local libdir=${ED}/usr/$(get_libdir)/python${SLOT}

	cd "${BUILD_DIR}" || die
	emake DESTDIR="${D}" altinstall || die "emake altinstall failed"

	local myrelfile=""
	for myfile in `find "${ED}"usr/ -type f; find "${ED}"usr/ -type l`; do
		myrelfile="${myfile/${ED}}"
		case "${myrelfile}" in
			*lib-tk*)
				true ;;
			*/tkinter/*)
				true ;;
			*_tkinter*.so)
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
	local found=$(find "${ED}" -name "_tkinter*.so")
	[ -z "${found}" ] && die "_tkinter*.so not installed"
}
