# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PATCH_VER="1.0"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
PIE_VER="0.5.2"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.32
SSP_UCLIBC_STABLE="x86 amd64 ppc ppc64 arm"
#end Hardened stuff

inherit eutils toolchain

# This is here to redeclare is_gcc() in toolchain.eclass
# We don't even want to build gcj, which is a real hog
# on memory constrained hardware. base-gcc doesn't actually
# ship with it atm.
is_gcj() {
	return 1
}

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"

RDEPEND=">=sys-libs/zlib-1.1.4
	virtual/libiconv
	>=dev-libs/gmp-4.3.2
	>=dev-libs/mpfr-2.4.2
	>=dev-libs/mpc-0.8.1
	graphite? (
		>=dev-libs/cloog-ppl-0.15.10
		>=dev-libs/ppl-0.11
	)
	!build? (
		nls? ( sys-devel/gettext )
	)"

DEPEND="${RDEPEND}
	test? (
		>=dev-util/dejagnu-1.4.4
		>=sys-devel/autogen-5.5.4
	)
	>=sys-apps/texinfo-4.8
	>=sys-devel/bison-1.875
	>=sys-devel/flex-2.5.4
	>=${CATEGORY}/binutils-2.18"

## Check for valid gcc profile.
src_unpack() {
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

	toolchain_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch
}

pkg_setup() {
	toolchain_pkg_setup

	ewarn
	ewarn "LTO support is still experimental and unstable."
	ewarn "Any bugs resulting from the use of LTO will not be fixed."
	ewarn
}

## Just install libgcc stuff
src_install() {
	cd "${WORKDIR}/build"
	S="${WORKDIR}"/build \
		emake -j1 -C "${CTARGET}/libgcc" DESTDIR="${D}" install-shared || die
	if use multilib; then
		S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/32/libgcc" DESTDIR="${D}" \
			install-shared || die
	fi

	if use mudflap; then
		S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/libmudflap" DESTDIR="${D}" \
			install-toolexeclibLTLIBRARIES || die
		if use multilib; then
			S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/32/libmudflap" DESTDIR="${D}" \
				install-toolexeclibLTLIBRARIES || die
		fi
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
	S="${WORKDIR}"/build emake -j1 -C "${CTARGET}/libgomp" DESTDIR="${D}" install-info || die

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

## Do nothing!
pkg_preinst() {
	:
}

pkg_postinst() {
	# Sabayon specific bits to always force the latest gcc profile
	local gcc_atom=$(best_version sys-devel/base-gcc)
	local gcc_ver=
	if [ -n "${gcc_atom}" ]; then
		elog "Found latest base-gcc to be: ${gcc_atom}, forcing this profile"
		gcc_ver=$(portageq metadata "${ROOT}" installed "${gcc_atom}" PV)
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

## Do nothing!
pkg_prerm() {
	:
}

## Do nothing!
pkg_postrm() {
	:
}
