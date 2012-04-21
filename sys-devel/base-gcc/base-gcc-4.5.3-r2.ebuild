# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PATCH_VER="1.1"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
PIE_VER="0.4.7"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 ppc ppc64"
SSP_STABLE="amd64 x86 ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
SSP_UCLIBC_STABLE=""
#end Hardened stuff

inherit toolchain

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	>=dev-libs/gmp-4.3.2
	>=dev-libs/mpfr-2.4.2
	>=dev-libs/mpc-0.8.1
	graphite? (
		>=dev-libs/ppl-0.10
		>=dev-libs/cloog-ppl-0.15.8
	)
	lto? ( || ( >=dev-libs/elfutils-0.143 dev-libs/libelf ) )
	!build? (
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"

DEPEND="${RDEPEND}
	test? ( >=dev-util/dejagnu-1.4.4 >=sys-devel/autogen-5.5.4 )
	>=sys-apps/texinfo-4.8
	>=sys-devel/bison-1.875
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	ppc? ( >=${CATEGORY}/binutils-2.17 )
	ppc64? ( >=${CATEGORY}/binutils-2.17 )
	>=${CATEGORY}/binutils-2.15.94"
PDEPEND=">=sys-devel/gcc-config-1.4"

## No changes
src_unpack() {
	toolchain_src_unpack

	use vanilla && return 0

	sed -i 's/use_fixproto=yes/:/' gcc/config.gcc #PR33200

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch
}

## Remove lto conditional
pkg_setup() {
	toolchain_pkg_setup
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

	# GCC 4.6 only
	#S="${WORKDIR}"/build emake -j1 DESTDIR="${D}" install-target-libquadmath || die
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

## Do nothing!
pkg_postinst() {
	:
}

## Do nothing!
pkg_prerm() {
	:
}

## Do nothing!
pkg_postrm() {
	:
}
