# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
PATCH_VER="1.0"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
PIE_VER="0.4.5"
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

RDEPEND="~sys-devel/base-gcc-${PV}
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				=x11-libs/gtk+-2*
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
	)"

## Make sure we share all the USE flags in sys-devel/base-gcc
BASE_GCC_USE="fortran gcj gtk mudflap multilib nls nptl openmp altivec
	bootstrap build doc fixed-point go graphite hardened
	multislot cxx nopie nossp objc objc++ objc-gc test vanilla"
for base_use in ${BASE_GCC_USE}; do
	RDEPEND+=" ~sys-devel/base-gcc-${PV}[${base_use}?]"
done
IUSE="${BASE_GCC_USE}"

DEPEND="${RDEPEND}
	amd64? ( multilib? ( gcj? ( app-emulation/emul-linux-x86-xlibs ) ) )"
## Should this be moved to base-gcc?
## I guess the cross-* thing is now utterly broken
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

## No changes
src_unpack() {
	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi

	# drop the x32 stuff once 4.7 goes stable
	case ${CHOST} in
	x86_64*) has x32 $(get_all_abis) || EPATCH_EXCLUDE+=" 80_all_gcc-4.6-x32.patch" ;;
	esac

	toolchain_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	# Fix http://gcc.gnu.org/bugzilla/show_bug.cgi?id=47719
	epatch "${FILESDIR}/${P}-fix-ICE-on-arm.patch"
}

## Remove lto conditional
pkg_setup() {
	toolchain_pkg_setup

	ewarn
	ewarn "LTO support is still experimental and unstable."
	ewarn "Any bugs resulting from the use of LTO will not be fixed."
	ewarn
}

## Just install libgcc stuff
src_install() {
	toolchain_src_install

	# now drop what's provided by sys-devel/base-gcc-${PV}:${SLOT}
	base_gcc_libs="libgfortran.so* libgcc_s.so* libobjc.so*
		libobjc_gc.so* libmudflap.so* libmudflapth.so* libgomp.so* libstdc++.so*
		libquadmath.so*"
	base_multilib_gcc_libs="32/libgfortran.so* 32/libobjc.so* 32/libobjc_gc.so*
		32/libgcc_s.so* 32/libgomp.so* 32/libmudflap.so*
		32/libmudflapth.so* 32/libstdc++.so* 32/libquadmath.so*"
	for gcc_lib in ${base_gcc_libs}; do
		# -f is used because the file might not be there
		rm "${D}"${LIBPATH}/${gcc_lib} -rf || die "cannot execute rm on ${gcc_lib}"
		debug_dir="${D}"/usr/lib/debug
		if [ -d "${debug_dir}" ]; then
			rm "${debug_dir}"${LIBPATH}/${gcc_lib}.debug -rf || die "cannot execute rm on ${gcc_lib}.debug"
		fi
	done
	if use multilib; then
		for gcc_lib in ${base_multilib_gcc_libs}; do
			# -f is used because the file might not be there
			rm "${D}"${LIBPATH}/${gcc_lib} -rf || die "cannot execute rm on ${gcc_lib}"
			debug_dir="${D}"/usr/lib/debug
			if [ -d "${debug_dir}" ]; then
				rm "${debug_dir}"${LIBPATH}/${gcc_lib}.debug -rf || die "cannot execute rm on ${gcc_lib}.debug"
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
