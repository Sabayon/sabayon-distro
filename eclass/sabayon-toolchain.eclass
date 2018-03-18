# Copyright 2017 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# Sabayon eclass to handle gcc/base-gcc split
# Maintainer: Ettore Di Giacinto <mudler@sabayon.org>

DESCRIPTION="The GNU Compiler Collection"
HOMEPAGE="https://gcc.gnu.org/"

inherit toolchain

EXPORTED_FUNCTIONS="pkg_setup src_unpack src_compile src_test src_install pkg_postinst pkg_postrm"
case ${EAPI:-0} in
	0|1)    die "Need to upgrade to at least EAPI=2";;
	2|3)    EXPORTED_FUNCTIONS+=" src_prepare src_configure" ;;
	4*|5*)  EXPORTED_FUNCTIONS+=" pkg_pretend src_prepare src_configure" ;;
	*)      die "I don't speak EAPI ${EAPI}."
esac
EXPORT_FUNCTIONS ${EXPORTED_FUNCTIONS}

#---->> pkg_pretend <<----

sabayon-toolchain_pkg_pretend() {
	toolchain_pkg_pretend
}

#---->> pkg_setup <<----

sabayon-toolchain_pkg_setup() {
	toolchain_pkg_setup
}

#---->> src_unpack <<----

sabayon-toolchain_src_unpack() {
	toolchain_src_unpack
}


#---->> src_prepare <<----

sabayon-toolchain_src_prepare() {
	einfo "Sabayon: prepare phase for sys-devel/{gcc,base-gcc}"
	# Since Sabayon's gcc ebuild are split into two parts, we have to
	# build gcc with a different version of gcc, or terrible breakage
	# will occur after sys-devel/base-gcc is installed, but the
	# partner sys-devel/gcc still needs to be built.

	# While it is possible to rebuild Sabayon's split gcc from
	# the same version, we have to disallow this also since
	# we have no way of discerning if a configuration change
	# is significant enough to cause breakage.

	GCC_PROFILE_VER=$(cat ${ROOT}/etc/env.d/gcc/config-$CHOST | awk -F- '{ print $NF }')
	einfo "Checking for valid gcc profile to build ${P}"

	# Construct the Slot of the gcc version in the active profile.
	GCC_PROFILE_SLOT_MAJOR=$(echo ${GCC_PROFILE_VER} | awk -F. '{ print $1 }')
	GCC_PROFILE_SLOT_MINOR=$(echo ${GCC_PROFILE_VER} | awk -F. '{ print $2 }')
	GCC_PROFILE_SLOT="${GCC_PROFILE_SLOT_MAJOR}.${GCC_PROFILE_SLOT_MINOR}"
	einfo "Current gcc profile version Slot is: ${GCC_PROFILE_SLOT}"
	if [[ "${GCC_PROFILE_SLOT}" = "${SLOT}" ]] ; then
		eerror "Error!"
		eerror "The active gcc-profile is for sys-devel/gcc slot ${SLOT}."
		eerror "Sabayon's split sys-devel/gcc package MUST be built"
		eerror "with another slotted version of sys-devel/gcc active."
		ebeep 10
	fi

	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi

	is_crosscompile && EPATCH_EXCLUDE+=" 05_all_gcc-spec-env.patch"

	toolchain_src_prepare
}

#---->> src_configure <<----

sabayon-toolchain_src_configure() {
	toolchain_src_configure
}

#----> src_compile <----

sabayon-toolchain_src_compile() {
	toolchain_src_compile
}

#---->> src_test <<----

sabayon-toolchain_src_test() {
	toolchain_src_test
}

#---->> src_install <<----

_install_basegcc(){
	einfo "Sabayon: install sys-devel/base-gcc files"

	cd "${WORKDIR}/build"
	S="${WORKDIR}"/build \
		emake -j1 -C "${CTARGET}/libgcc" DESTDIR="${D}" install-shared || die
	if use multilib; then
		S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/32/libgcc" DESTDIR="${D}" \
			install-shared || die
	fi

	if use openmp; then
		S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/libgomp" DESTDIR="${D}" \
			install-toolexeclibLTLIBRARIES || die
		if use multilib; then
			S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/32/libgomp" DESTDIR="${D}" \
				install-toolexeclibLTLIBRARIES || die
		fi
	fi

	S="${WORKDIR}"/build \
		emake -j1 -C "${CTARGET}/libstdc++-v3/src" DESTDIR="${D}" \
		install-toolexeclibLTLIBRARIES || die
	if use multilib; then
		S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/32/libstdc++-v3/src" DESTDIR="${D}" \
			install-toolexeclibLTLIBRARIES || die
	fi

	S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/libstdc++-v3/po" DESTDIR="${D}" install || die
	if use openmp; then
		S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/libgomp" DESTDIR="${D}" install-info || die
	fi

	S="${WORKDIR}"/build emake -j1 DESTDIR="${D}" install-target-libquadmath || die
	if use fortran; then
		S="${WORKDIR}"/build emake -j1 DESTDIR="${D}" install-target-libgfortran || die
	fi
	# TODO: what to do with USE objc++ and objc-gc ?
	if use objc; then
		S="${WORKDIR}"/build emake -j1 DESTDIR="${D}" install-target-libobjc || die
	fi

	# from toolchain.eclass yay
	gcc_movelibs

	dodir /etc/env.d/gcc
	create_gcc_env_entry

	# Setup the gcc_env_entry for hardened gcc 4 with minispecs
	if want_minispecs ; then
		copy_minispecs_gcc_specs
	fi

	# drop any .la, .a
	find "${D}" -name *.a -delete
	find "${D}" -name *.la -delete

	# drop any include
	rm "${D}${LIBPATH}"/include -rf
	# drop specs as well, provided by sys-devel/gcc-${PV}:${SLOT}
	# unfortunately, the spec shit above does create the env.d/
	# file content...
	rm "${D}${LIBPATH}"/{32/,}*.spec{s,} -rf
	rm "${D}${LIBPATH}"/specs -rf

	# Now do the fun stripping stuff
	env RESTRICT="" CHOST=${CTARGET} prepstrip "${D}${LIBPATH}"

	cd "${S}"
	if ! is_crosscompile; then
		has noinfo ${FEATURES} \
			&& rm -r "${D}/${DATAPATH}"/info \
			|| prepinfo "${DATAPATH}"
	fi

	# use gid of 0 because some stupid ports don't have
	# the group 'root' set to gid 0
	chown -R root:0 "${D}"${LIBPATH}
}

_install_gcc() {
	einfo "Sabayon: install sys-devel/gcc files (including compiler)"
	toolchain_src_install
	# now drop what's provided by sys-devel/base-gcc-${PV}:${SLOT}
	base_gcc_libs="libgfortran.so* libgcc_s.so* libobjc.so*
		libobjc_gc.so* libmudflap.so* libmudflapth.so* libgomp.so* libgomp-plugin-host_nonshm.so* libstdc++.so* libquadmath.so*
		crtprec80.o crtbeginP.o crtfastmath.o crtprec32.o crtbeginT.o
		crtbeginS.o crtbegin.o crtend.o crtendS.o crtprec64.o
		vtv_end.o vtv_end_preinit.o vtv_start.o vtv_start_preinit.o
		finclude/ieee_arithmetic.mod finclude/ieee_exceptions.mod finclude/ieee_features.mod"
	base_multilib_gcc_libs="32/libgfortran.so* 32/libobjc.so* 32/libobjc_gc.so*
		32/libgcc_s.so* 32/libgomp.so* 32/libgomp-plugin-host_nonshm.so* 32/libmudflap.so*
		32/libmudflapth.so* 32/libstdc++.so* 32/libquadmath.so*
		32/crtprec80.o 32/crtbeginP.o 32/crtfastmath.o 32/crtprec32.o 32/crtbeginT.o
		32/crtbeginS.o 32/crtbegin.o 32/crtend.o 32/crtendS.o 32/crtprec64.o
		32/vtv_end.o 32/vtv_end_preinit.o 32/vtv_start.o 32/vtv_start_preinit.o
		32/finclude/ieee_arithmetic.mod 32/finclude/ieee_exceptions.mod 32/finclude/ieee_features.mod"
	for gcc_lib in ${base_gcc_libs}; do
		# -f is used because the file might not be there
		rm "${D}"${LIBPATH}/${gcc_lib} -rf || ewarn "cannot execute rm on ${gcc_lib}"
		debug_dir="${D}"/usr/lib/debug
		if [ -d "${debug_dir}" ]; then
			rm "${debug_dir}"${LIBPATH}/${gcc_lib}.debug -rf || ewarn "cannot execute rm on ${gcc_lib}.debug"
		fi
	done
	if use multilib; then
		for gcc_lib in ${base_multilib_gcc_libs}; do
			# -f is used because the file might not be there
			rm "${D}"${LIBPATH}/${gcc_lib} -rf || ewarn "cannot execute rm on ${gcc_lib}"
			debug_dir="${D}"/usr/lib/debug
			if [ -d "${debug_dir}" ]; then
				rm "${debug_dir}"${LIBPATH}/${gcc_lib}.debug -rf || ewarn "cannot execute rm on ${gcc_lib}.debug"
			fi
		done
	fi
	# then .mo files provided by sys-devel/base-gcc-${PV}:${SLOT}
	find "${D}"${DATAPATH}/locale -name libstdc++.mo -delete
	find "${D}"${DATAPATH}/info -name libgomp.info* -delete
	find "${D}"${DATAPATH}/info -name libquadmath.info* -delete

	# drop stuff from env.d, provided by sys-devel/base-gcc-${PV}:${SLOT}
	rm "${D}"/etc/env.d -rf
}

sabayon-toolchain_src_install() {
	if [[ ${PN} == "gcc" ]] ; then
		_install_gcc
	elif [[ ${PN} == "base-gcc" ]] ; then
		_install_basegcc
	fi
}

#---->> pkg_post* <<----

_postinst_basegcc(){
	# Sabayon specific bits to always force the latest gcc profile
	local gcc_atom=$(best_version sys-devel/base-gcc)
	local gcc_ver=
	if [ -n "${gcc_atom}" ]; then
		elog "Found latest base-gcc to be: ${gcc_atom}, forcing this profile"
		gcc_ver=$(/usr/bin/portageq metadata "${ROOT}" installed "${gcc_atom}" PV)
	else
		eerror "No sys-devel/base-gcc installed"
	fi

	if [ -n "${gcc_ver}" ]; then
		local target="${CTARGET:${CHOST}}-${gcc_ver}"
		local env_target="${ROOT}/etc/env.d/gcc/${target}"
		[[ -e "${env_target}-vanilla" ]] && find_target="${target}-vanilla"

		elog "Setting: ${target} GCC profile"
		gcc-config "${target}"
	else
		eerror "No sys-devel/base-gcc version installed? Cannot set a proper GCC profile"
	fi
}

sabayon-toolchain_pkg_postinst() {
	if [[ ${PN} == "gcc" ]] ; then
		toolchain_pkg_postinst
	elif [[ ${PN} == "base-gcc" ]] ; then
		_postinst_basegcc
	fi
}

sabayon-toolchain_pkg_postrm() {
	toolchain_pkg_postrm
}
