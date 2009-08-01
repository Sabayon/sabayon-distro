# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.39.0.ebuild,v 1.2 2009/07/16 09:36:51 dev-zero Exp $

EAPI="2"

inherit python flag-o-matic multilib toolchain-funcs versionator check-reqs

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

MY_P=${PN}_$(replace_all_version_separators _)
PATCHSET_VERSION="${PV}-1"

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="http://www.boost.org/"
SRC_URI="mirror://sourceforge/boost/${MY_P}.tar.bz2
	mirror://gentoo/boost-patches-${PATCHSET_VERSION}.tbz2
	http://www.gentoo.org/~dev-zero/distfiles/boost-patches-${PATCHSET_VERSION}.tbz2"
LICENSE="freedist Boost-1.0"
SLOT="$(get_version_component_range 1-2)"
IUSE="debug doc +eselect expat icu mpi python tools"

RDEPEND="icu? ( >=dev-libs/icu-3.3 )
	expat? ( dev-libs/expat )
	mpi? ( || ( >=sys-cluster/openmpi-1.3[cxx] =sys-cluster/openmpi-1.2*[-nocxx] ) )
	sys-libs/zlib
	python? ( virtual/python )
	!!<=dev-libs/boost-1.35.0-r2
	>=app-admin/eselect-boost-0.3"
DEPEND="${RDEPEND}
	dev-util/boost-build:${SLOT}"

S=${WORKDIR}/${MY_P}

MAJOR_PV=$(replace_all_version_separators _ ${SLOT})
BJAM="bjam-${MAJOR_PV}"

# Usage:
# _add_line <line-to-add> <profile>
# ... to add to specific profile
# or
# _add_line <line-to-add>
# ... to add to all profiles for which the use flag set

_add_line() {
	if [ -z "$2" ] ; then
		echo "${1}" >> "${D}/usr/share/boost-eselect/profiles/${SLOT}/default"
		use debug && echo "${1}" >> "${D}/usr/share/boost-eselect/profiles/${SLOT}/debug"
	else
		echo "${1}" >> "${D}/usr/share/boost-eselect/profiles/${SLOT}/${2}"
	fi
}

pkg_setup() {
	if has test ${FEATURES} ; then
		CHECKREQS_DISK_BUILD="1024"
		check_reqs

		ewarn "The tests may take several hours on a recent machine"
		ewarn "but they will not fail (unless something weird happens ;-)"
		ewarn "This is because the tests depend on the used compiler/-version"
		ewarn "and the platform and upstream says that this is normal."
		ewarn "If you are interested in the results, please take a look at the"
		ewarn "generated results page:"
		ewarn "  ${ROOT}usr/share/doc/${PF}/status/cs-$(uname).html"
		ebeep 5

	fi

	if use debug ; then
		ewarn "The debug USE-flag means that a second set of the boost libraries"
		ewarn "will be built containing debug-symbols. You'll be able to select them"
		ewarn "using the boost-eselect module. But even though the optimization flags"
		ewarn "you might have set are not stripped, there will be a performance"
		ewarn "penalty and linking other packages against the debug version"
		ewarn "of boost is _not_ recommended."
	fi
}

src_prepare() {
	EPATCH_SOURCE="${WORKDIR}/patches"
	EPATCH_SUFFIX="patch"
	epatch

	epatch "${FILESDIR}/remove_toolset_from_targetname.patch"
	epatch "${FILESDIR}/${P}-fix-include.patch"

	# This enables building the boost.random library with /dev/urandom support
	if [[ -e /dev/urandom ]] ; then
		mkdir -p libs/random/build
		cp "${FILESDIR}/random-Jamfile" libs/random/build/Jamfile.v2
		# yeah, we WANT it to work on non-Linux too
		sed -i -e 's/#ifdef __linux__/#if 1/' libs/random/random_device.cpp || die
	fi
}

src_configure() {
	einfo "Writing new user-config.jam"

	local compiler compilerVersion compilerExecutable mpi
	if [[ ${CHOST} == *-darwin* ]] ; then
		compiler=darwin
		compilerVersion=$(gcc-fullversion)
		compilerExecutable=$(tc-getCXX)
		# we need to add the prefix, and in two cases this exceeds, so prepare
		# for the largest possible space allocation
		append-ldflags -Wl,-headerpad_max_install_names
	else
		compiler=gcc
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
	fi

	use mpi && mpi="using mpi ;"

	if use python ; then
		python_version
		pystring="using python : ${PYVER} : /usr :	/usr/include/python${PYVER} : /usr/lib/python${PYVER} ;"
	fi

	cat > "${S}/user-config.jam" << __EOF__

variant gentoorelease : release : <optimization>none <debug-symbols>none ;
variant gentoodebug : debug : <optimization>none ;

using ${compiler} : ${compilerVersion} : ${compilerExecutable} : <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;

${pystring}

${mpi}

__EOF__

	# Maintainer information:
	# The debug-symbols=none and optimization=none
	# are not official upstream flags but a Gentoo
	# specific patch to make sure that all our
	# CXXFLAGS/LDFLAGS are being respected.
	# Using optimization=off would for example add
	# "-O0" and override "-O2" set by the user.
	# Please take a look at the boost-build ebuild
	# for more infomration.

	use icu && OPTIONS="-sICU_PATH=/usr"
	use expat && OPTIONS="${OPTIONS} -sEXPAT_INCLUDE=/usr/include -sEXPAT_LIBPATH=/usr/$(get_libdir)"
	use mpi || OPTIONS="${OPTIONS} --without-mpi"
	use python || OPTIONS="${OPTIONS} --without-python"

	OPTIONS="${OPTIONS} --user-config=\"${S}/user-config.jam\" --boost-build=/usr/share/boost-build-${MAJOR_PV} --prefix=\"${D}/usr\" --layout=versioned"

}

src_compile() {

	NUMJOBS=$(sed -e 's/.*\(\-j[ 0-9]\+\) .*/\1/; s/--jobs=\?/-j/' <<< ${MAKEOPTS})

	einfo "Using the following options to build: "
	einfo "  ${OPTIONS}"

	export BOOST_ROOT="${S}"

	${BJAM} ${NUMJOBS} -q \
		gentoorelease \
		${OPTIONS} \
		threading=single,multi link=shared,static runtime-link=shared \
		|| die "building boost failed"

	# ... and do the whole thing one more time to get the debug libs
	if use debug ; then
		${BJAM} ${NUMJOBS} -q \
			gentoodebug \
			${OPTIONS} \
			threading=single,multi link=shared,static runtime-link=shared \
			--buildid=debug \
			|| die "building boost failed"
	fi

	if use tools; then
		cd "${S}/tools/"
		${BJAM} ${NUMJOBS} -q \
			gentoorelease \
			${OPTIONS} \
			|| die "building tools failed"
	fi

}

src_install () {
	einfo "Using the following options to install: "
	einfo "  ${OPTIONS}"

	export BOOST_ROOT="${S}"

	${BJAM} -q \
		gentoorelease \
		${OPTIONS} \
		threading=single,multi link=shared,static runtime-link=shared \
		--includedir="${D}/usr/include" \
		--libdir="${D}/usr/$(get_libdir)" \
		install || die "install failed for options '${OPTIONS}'"

	if use debug ; then
		${BJAM} -q \
			gentoodebug \
			${OPTIONS} \
			threading=single,multi link=shared,static runtime-link=shared \
			--includedir="${D}/usr/include" \
			--libdir="${D}/usr/$(get_libdir)" \
			--buildid=debug \
			install || die "install failed for options '${OPTIONS}'"
	fi

	use python || rm -rf "${D}/usr/include/boost-${MAJOR_PV}/boost"/python*

	dodir /usr/share/boost-eselect/profiles/${SLOT}
	touch "${D}/usr/share/boost-eselect/profiles/${SLOT}/default"
	use debug && touch "${D}/usr/share/boost-eselect/profiles/${SLOT}/debug"

	# Move the mpi.so to the right place and make sure it's slotted
	if use mpi && use python; then
		mkdir -p "${D}/usr/$(get_libdir)/python${PYVER}/site-packages/boost_${MAJOR_PV}"
		mv "${D}/usr/$(get_libdir)/mpi.so" "${D}/usr/$(get_libdir)/python${PYVER}/site-packages/boost_${MAJOR_PV}/"
		touch "${D}/usr/$(get_libdir)/python${PYVER}/site-packages/boost_${MAJOR_PV}/__init__.py"
		_add_line "python=\"/usr/$(get_libdir)/python${PYVER}/site-packages/boost_${MAJOR_PV}/mpi.so\""
	fi

	if use doc ; then
		find libs/*/* -iname "test" -or -iname "src" | xargs rm -rf
		dohtml \
			-A pdf,txt,cpp,hpp \
			*.{htm,html,png,css} \
			-r doc more people wiki
		dohtml \
			-A pdf,txt \
			-r tools
		insinto /usr/share/doc/${PF}/html
		doins -r libs

		# To avoid broken links
		insinto /usr/share/doc/${PF}/html
		doins LICENSE_1_0.txt

		dosym /usr/include/boost /usr/share/doc/${PF}/html/boost
	fi

	cd "${D}/usr/$(get_libdir)"

	# Remove (unversioned) symlinks
	# And check for what we remove to catch bugs
	# got a better idea how to do it? tell me!
	for f in $(ls -1 *{.a,$(get_libname)} | grep -v "${MAJOR_PV}") ; do
		if [ ! -h "${f}" ] ; then
			eerror "Ups, tried to remove '${f}' which is a a real file instead of a symlink"
			die "slotting/naming of the libs broken!"
		fi
		rm "${f}"
	done

	# The threading libs obviously always gets the "-mt" (multithreading) tag
	# some packages seem to have a problem with it. Creating symlinks...
	for lib in libboost_thread-mt-${MAJOR_PV}{.a,$(get_libname)} ; do
		dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
	done

	# The same goes for the mpi libs
	if use mpi ; then
		for lib in libboost_mpi-mt-${MAJOR_PV}{.a,$(get_libname)} ; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
		done
	fi

	if use debug ; then
		for lib in libboost_thread-mt-${MAJOR_PV}-debug{.a,$(get_libname)} ; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
		done

		if use mpi ; then
			for lib in libboost_mpi-mt-${MAJOR_PV}-debug{.a,$(get_libname)} ; do
				dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
			done
		fi
	fi

	# Create a subdirectory with completely unversioned symlinks
	# and store the names in the profiles-file for eselect
	dodir /usr/$(get_libdir)/boost-${MAJOR_PV}

	_add_line "libs=\"" default
	for f in $(ls -1 *{.a,$(get_libname)} | grep -v debug) ; do
		dosym ../${f} /usr/$(get_libdir)/boost-${MAJOR_PV}/${f/-${MAJOR_PV}}
		_add_line "/usr/$(get_libdir)/${f}" default
	done
	_add_line "\"" default

	if use debug ; then
		_add_line "libs=\"" debug
		dodir /usr/$(get_libdir)/boost-${MAJOR_PV}-debug
		for f in $(ls -1 *{.a,$(get_libname)} | grep debug) ; do
			dosym ../${f} /usr/$(get_libdir)/boost-${MAJOR_PV}-debug/${f/-${MAJOR_PV}-debug}
			_add_line "/usr/$(get_libdir)/${f}" debug
		done
		_add_line "\"" debug

		_add_line "includes=\"/usr/include/boost-${MAJOR_PV}/boost\"" debug
		_add_line "suffix=\"-debug\"" debug
	fi

	_add_line "includes=\"/usr/include/boost-${MAJOR_PV}/boost\"" default

	if use tools; then
		cd "${S}/dist/bin"
		# Append version postfix to binaries for slotting
		_add_line "bins=\""
		for b in * ; do
			newbin "${b}" "${b}-${MAJOR_PV}"
			_add_line "/usr/bin/${b}-${MAJOR_PV}"
		done
		_add_line "\""

		cd "${S}/dist"
		insinto /usr/share
		doins -r share/boostbook
		# Append version postfix for slotting
		mv "${D}/usr/share/boostbook" "${D}/usr/share/boostbook-${MAJOR_PV}"
		_add_line "dirs=\"/usr/share/boostbook-${MAJOR_PV}\""
	fi

	cd "${S}/status"
	if [ -f regress.log ] ; then
		docinto status
		dohtml *.{html,gif} ../boost.png
		dodoc regress.log
	fi

	use python && python_need_rebuild

	# boost's build system truely sucks for not having a destdir.  Because for
	# this reason we are forced to build with a prefix that includes the
	# DESTROOT, dynamic libraries on Darwin end messed up, referencing the
	# DESTROOT instread of the actual EPREFIX.  There is no way out of here
	# but to do it the dirty way of manually setting the right install_names.
	[[ -z ${ED+set} ]] && local ED=${D%/}${EPREFIX}/
	if [[ ${CHOST} == *-darwin* ]] ; then
		einfo "Working around completely broken build-system(tm)"
		for d in "${ED}"usr/lib/*.dylib ; do
			if [[ -f ${d} ]] ; then
				# fix the "soname"
				ebegin "  correcting install_name of ${d#${ED}}"
				install_name_tool -id "/${d#${D}}" "${d}"
				eend $?
				# fix references to other libs
				refs=$(otool -XL "${d}" | \
					sed -e '1d' -e 's/^\t//' | \
					grep "^libboost_" | \
					cut -f1 -d' ')
				for r in ${refs} ; do
					ebegin "    correcting reference to ${r}"
					install_name_tool -change \
						"${r}" \
						"${EPREFIX}/usr/lib/${r}" \
						"${d}"
					eend $?
				done
			fi
		done
	fi
}

src_test() {
	export BOOST_ROOT=${S}

	cd "${S}/tools/regression/build"
	${BJAM} -q \
		gentoorelease \
		${OPTIONS} \
		process_jam_log compiler_status \
		|| die "building regression test helpers failed"

	cd "${S}/status"

	# Some of the test-checks seem to rely on regexps
	export LC_ALL="C"

	# The following is largely taken from tools/regression/run_tests.sh,
	# but adapted to our needs.

	# Run the tests & write them into a file for postprocessing
	${BJAM} \
		${OPTIONS} \
		--dump-tests 2>&1 | tee regress.log

	# Postprocessing
	cat regress.log | "${S}/tools/regression/build/bin/gcc-$(gcc-version)/gentoorelease/process_jam_log" --v2
	if test $? != 0 ; then
		die "Postprocessing the build log failed"
	fi

	cat > "${S}/status/comment.html" <<- __EOF__
		<p>Tests are run on a <a href="http://www.gentoo.org">Gentoo</a> system.</p>
__EOF__

	# Generate the build log html summary page
	"${S}/tools/regression/build/bin/gcc-$(gcc-version)/gentoorelease/compiler_status" --v2 \
		--comment "${S}/status/comment.html" "${S}" \
		cs-$(uname).html cs-$(uname)-links.html
	if test $? != 0 ; then
		die "Generating the build log html summary page failed"
	fi

	# And do some cosmetic fixes :)
	sed -i -e 's|http://www.boost.org/boost.png|boost.png|' *.html
}

pkg_postinst() {
	use eselect && eselect boost update
	if [ ! -h "${ROOT}/etc/eselect/boost/active" ] ; then
		elog "No active boost version found. Calling eselect to select one..."
		eselect boost update
	fi
}
