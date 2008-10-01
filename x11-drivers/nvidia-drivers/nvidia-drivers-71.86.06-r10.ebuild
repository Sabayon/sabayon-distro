# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/nvidia-drivers/nvidia-drivers-71.86.06.ebuild,v 1.3 2008/07/22 15:27:39 chainsaw Exp $

inherit eutils multilib versionator linux-mod flag-o-matic nvidia-driver

X86_NV_PACKAGE="NVIDIA-Linux-x86-${PV}"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"
X86_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86-${PV}"

DESCRIPTION="NVIDIA X11 driver and GLX libraries"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="x86? ( http://us.download.nvidia.com/XFree86/Linux-x86/${PV}/${X86_NV_PACKAGE}-pkg0.run )
	 amd64? ( http://us.download.nvidia.com/XFree86/Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}-pkg2.run )"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="acpi gtk multilib distribution"
RESTRICT="strip"
EMULTILIB_PKG="true"

COMMON="x11-base/xorg-server
	multilib? ( app-emulation/emul-linux-x86-xlibs )
	kernel_FreeBSD? ( !media-video/nvidia-freebsd )
	!app-emulation/emul-linux-x86-nvidia
	!x11-drivers/nvidia-legacy-drivers"
DEPEND="${COMMON}
	kernel_linux? ( virtual/linux-sources )
	app-admin/eselect-opengl"
RDEPEND="${COMMON}
	kernel_linux? ( virtual/modutils )
	media-libs/mesa
	acpi? ( sys-power/acpid )"
PDEPEND="gtk? ( media-video/nvidia-settings )"

QA_TEXTRELS_x86="usr/lib/xorg/libXvMCNVIDIA.so.${PV}
	usr/lib/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib/opengl/nvidia/lib/libGLcore.so.${PV}
	usr/lib/opengl/nvidia/lib/libnvidia-cfg.so.${PV}
	usr/lib/opengl/nvidia/tls/libnvidia-tls.so.${PV}
	usr/lib/opengl/nvidia/no-tls/libnvidia-tls.so.${PV}
	usr/lib/libXvMCNVIDIA.so.${PV}
	usr/lib/xorg/modules/drivers/nvidia_drv.so
	usr/lib/opengl/nvidia/extensions/libglx.so"

QA_TEXTRELS_x86_fbsd="boot/modules/nvidia.ko
	usr/lib/opengl/nvidia/lib/libGL.so.1
	usr/lib/opengl/nvidia/lib/libGLcore.so.1
	usr/lib/opengl/nvidia/lib/libnvidia-cfg.so.${PV}
	usr/lib/opengl/nvidia/no-tls/libnvidia-tls.so.1
	usr/lib/opengl/nvidia/extensions/libglx.so
	usr/lib/xorg/modules/drivers/nvidia_drv.so"

QA_WX_LOAD_x86="usr/lib/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib/opengl/nvidia/lib/libGLcore.so.${PV}
	usr/lib/opengl/nvidia/extensions/libglx.so"

QA_TEXTRELS_amd64="usr/lib64/xorg/libXvMCNVIDIA.so.${PV}
	usr/lib64/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib64/opengl/nvidia/lib/libGLcore.so.${PV}
	usr/lib64/opengl/nvidia/lib/libnvidia-cfg.so.${PV}
	usr/lib64/opengl/nvidia/tls/libnvidia-tls.so.${PV}
	usr/lib64/opengl/nvidia/no-tls/libnvidia-tls.so.${PV}
	usr/lib64/libXvMCNVIDIA.so.${PV}
	usr/lib64/xorg/modules/drivers/nvidia_drv.so
	usr/lib64/opengl/nvidia/extensions/libglx.so
	usr/lib32/xorg/libXvMCNVIDIA.so.${PV}
	usr/lib32/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib32/opengl/nvidia/lib/libGLcore.so.${PV}
	usr/lib32/opengl/nvidia/lib/libnvidia-cfg.so.${PV}
	usr/lib32/opengl/nvidia/tls/libnvidia-tls.so.${PV}
	usr/lib32/opengl/nvidia/no-tls/libnvidia-tls.so.${PV}
	usr/lib32/libXvMCNVIDIA.so.${PV}
	usr/lib32/xorg/modules/drivers/nvidia_drv.so
	usr/lib32/opengl/nvidia/extensions/libglx.so"

QA_WX_LOAD_amd64="usr/lib64/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib64/opengl/nvidia/lib/libGLcore.so.${PV}
	usr/lib64/opengl/nvidia/extensions/libglx.so
	usr/lib32/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib32/opengl/nvidia/lib/libGLcore.so.${PV}
	usr/lib32/opengl/nvidia/extensions/libglx.so"

QA_EXECSTACK_amd64="usr/lib64/xorg/modules/drivers/nvidia_drv.so
	usr/lib64/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib64/opengl/nvidia/lib/libnvidia-cfg.so.${PV}
	usr/lib64/opengl/nvidia/extensions/libglx.so
	usr/lib64/libXvMCNVIDIA.so.${PV}
	usr/bin/nvidia-xconfig"

QA_EXECSTACK_x86="usr/lib/xorg/modules/drivers/nvidia_drv.so
	usr/lib/opengl/nvidia/lib/libGL.so.${PV}
	usr/lib/opengl/nvidia/lib/libnvidia-cfg.so.${PV}
	usr/lib/opengl/nvidia/extensions/libglx.so
	usr/lib/libXvMCNVIDIA.so.${PV}
	usr/bin/nvidia-xconfig"

export _POSIX2_VERSION="199209"

if use x86; then
	PKG_V="-pkg0"
	NV_PACKAGE="${X86_NV_PACKAGE}"
elif use amd64; then
	PKG_V="-pkg2"
	NV_PACKAGE="${AMD64_NV_PACKAGE}"
elif use x86-fbsd; then
	PKG_V=""
	NV_PACKAGE="${X86_FBSD_NV_PACKAGE}"
fi

S="${WORKDIR}/${NV_PACKAGE}${PKG_V}/usr/src/nv"

# On BSD userland it wants real make command
MAKE="make"

mtrr_check() {
	ebegin "Checking for MTRR support"
	linux_chkconfig_present MTRR
	eend $?

	if [[ $? -ne 0 ]] ; then
		eerror "This version needs MTRR support for most chipsets!"
		eerror "Please enable MTRR support in your kernel config, found at:"
		eerror
		eerror "  Processor type and features"
		eerror "    [*] MTRR (Memory Type Range Register) support"
		eerror
		eerror "and recompile your kernel ..."
		die "MTRR support not detected!"
	fi
}

pkg_setup() {
	if use amd64 && has_multilib_profile && [ "${DEFAULT_ABI}" != "amd64" ]; then
		eerror "This ebuild doesn't currently support changing your default abi."
		die "Unexpected \${DEFAULT_ABI} = ${DEFAULT_ABI}"
	fi

	if ! use x86-fbsd; then
		linux-mod_pkg_setup
		MODULE_NAMES="nvidia(video:${S})"
		BUILD_PARAMS="IGNORE_CC_MISMATCH=yes V=1 SYSSRC=${KV_DIR} SYSOUT=${KV_OUT_DIR}"
		mtrr_check
	fi

	# Since Nvidia ships 3 different series of drivers, we need to give the user
	# some kind of guidance as to what version they should install. This tries
	# to point the user in the right direction but can't be perfect. check
	# nvidia-driver.eclass
	nvidia-driver-check-warning
}

src_unpack() {
	local NV_PATCH_PREFIX="${FILESDIR}/${PV}/NVIDIA-${PV}"

	if ! use x86-fbsd; then
		if [[ ${KV_MINOR} -eq 6 && ${KV_PATCH} -lt 7 ]] ; then
			echo
			ewarn "Your kernel version is ${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}"
			ewarn "This is not officially supported for ${P}. It is likely you"
			ewarn "will not be able to compile or use the kernel module."
			ewarn "It is recommended that you upgrade your kernel to a version >= 2.6.7"
			echo
			ewarn "DO NOT file bug reports for kernel versions less than 2.6.7 as they will be ignored."
		fi
	fi

	if ! use x86-fbsd; then
		cd "${WORKDIR}"
		bash "${DISTDIR}/${NV_PACKAGE}${PKG_V}.run" --extract-only
	else
		unpack ${A}
	fi

	# Patches go below here, add brief description
	use x86-fbsd \
		&& cd "${WORKDIR}/${NV_PACKAGE}${PKG_V}/doc" \
		|| cd "${WORKDIR}/${NV_PACKAGE}${PKG_V}"
	# Use the correct defines to make gtkglext build work
	epatch "${FILESDIR}"/NVIDIA_glx-defines.patch
	# Use some more sensible gl headers and make way for new glext.h
	epatch "${FILESDIR}"/NVIDIA_glx-glheader.patch

	if ! use x86-fbsd; then
		# Quiet down warnings the user does not need to see
		sed -i \
			-e 's:-Wpointer-arith::g' \
			-e 's:-Wsign-compare::g' \
			"${S}"/Makefile.kbuild

		# If you set this then it's your own fault when stuff breaks :)
		[[ -n ${USE_CRAZY_OPTS} ]] && sed -i "s:-O:${CFLAGS}:" Makefile.*

		# If greater than 2.6.5 use M= instead of SUBDIR=
		cd "${S}"; convert_to_m Makefile.kbuild
	fi
}

src_compile() {
	# This is already the default on Linux, as there's no toplevel Makefile, but
	# on FreeBSD there's one and triggers the kernel module build, as we install
	# it by itself, pass this.
	if use x86-fbsd; then
		cd "${WORKDIR}/${NV_PACKAGE}${PKG_V}/src"
		echo LDFLAGS="$(raw-ldflags)"
		MAKE="$(get_bmake)" emake CC="$(tc-getCC)" LD="$(tc-getLD)" LDFLAGS="$(raw-ldflags)" || die
	else
		linux-mod_src_compile
	fi
}

src_install() {
	local MLTEST=$(type dyn_unpack)

	cd "${WORKDIR}"/${NV_PACKAGE}${PKG_V}

	if ! use x86-fbsd; then
		linux-mod_src_install

		VIDEOGROUP="$(egetent group video | cut -d ':' -f 3)"
		if [ -z "$VIDEOGROUP" ]; then
			eerror "Failed to determine the video group gid."
			die "Failed to determine the video group gid."
		fi

		# Add the aliases
		[ -f "${FILESDIR}/nvidia" ] || die "nvidia missing in FILESDIR"
		sed -e 's:PACKAGE:'${PF}':g' \
			-e 's:VIDEOGID:'${VIDEOGROUP}':' "${FILESDIR}"/nvidia > \
			"${WORKDIR}"/nvidia
		insinto /etc/modprobe.d
		doins "${WORKDIR}"/nvidia || die
	else
		insinto /boot/modules
		doins "${WORKDIR}/${X86_FBSD_NV_PACKAGE}/src/nvidia.kld" || die

		exeinto /boot/modules
		doexe "${WORKDIR}/${X86_FBSD_NV_PACKAGE}/src/nvidia.ko" || die
	fi

	if [[ "${MLTEST/set_abi}" == "${MLTEST}" ]] && has_multilib_profile ; then
		local OABI=${ABI}
		for ABI in $(get_install_abis) ; do
			src_install-libs
		done
		ABI=${OABI}
		unset OABI
	elif use amd64 ; then
		src_install-libs lib32 $(get_multilibdir)
		src_install-libs lib $(get_libdir)

		rm -rf "${D}"/usr/$(get_multilibdir)/opengl/nvidia/include
		rm -rf "${D}"/usr/$(get_multilibdir)/opengl/nvidia/extensions
	else
		src_install-libs
	fi

	is_final_abi || return 0

	if ! use x86-fbsd; then
		# Docs
		dodoc usr/share/doc/NVIDIA_Changelog
		dodoc usr/share/doc/XF86Config.sample
		dohtml usr/share/doc/html/*

		# nVidia want bug reports using this script
		dobin usr/bin/nvidia-bug-report.sh || die
	else
		dodoc doc/{README,XF86Config.sample,Copyrights}
		dohtml doc/html/*
	fi

        if use distribution && ! use x86-fbsd; then
                insinto /lib/nvidia
                doins "${WORKDIR}/${NV_PACKAGE}${PKG_V}/usr/src/nv/nvidia.o"
                insinto /lib/nvidia
                doins "${WORKDIR}/${NV_PACKAGE}${PKG_V}/usr/src/nv/nvidia.mod.o"
        fi

}

# Install nvidia library:
# the first parameter is the place where to install it
# the second parameter is the base name of the library
# the third parameter is the provided soversion
donvidia() {
	dodir $1
	exeinto $1

	libname=$(basename $2)

	doexe $2.$3
	dosym ${libname}.$3 $1/${libname}

	[[ $3 != "1" ]] && dosym ${libname}.$3 $1/${libname}.1
}

src_install-libs() {
	local pkglibdir=lib
	local inslibdir=$(get_libdir)

	if [[ ${#} -eq 2 ]] ; then
		pkglibdir=${1}
		inslibdir=${2}
	elif has_multilib_profile && [[ ${ABI} == "x86" ]] ; then
		pkglibdir=lib32
	fi

	local usrpkglibdir=usr/${pkglibdir}
	local libdir=usr/X11R6/${pkglibdir}
	local drvdir=${libdir}/modules/drivers
	local extdir=${libdir}/modules/extensions
	local incdir=usr/include/GL
	local sover=${PV}
	local NV_ROOT="/usr/${inslibdir}/opengl/nvidia"
	local NO_TLS_ROOT="${NV_ROOT}/no-tls"
	local TLS_ROOT="${NV_ROOT}/tls"
	local X11_LIB_DIR="/usr/${inslibdir}/xorg"

	if ! has_version x11-base/xorg-server ; then
		X11_LIB_DIR="/usr/${inslibdir}"
	fi

	if use x86-fbsd; then
		# on FreeBSD everything is on obj/
		pkglibdir=obj
		usrpkglibdir=obj
		x11pkglibdir=obj
		drvdir=obj
		extdir=obj

		# don't ask me why the headers are there.. glxext.h is missing
		incdir=doc

		# on FreeBSD it has just .1 suffix
		sover=1
	fi

	# The GLX libraries
	donvidia ${NV_ROOT}/lib ${usrpkglibdir}/libGL.so ${sover}
	donvidia ${NV_ROOT}/lib ${usrpkglibdir}/libGLcore.so ${sover}

	dodir ${NO_TLS_ROOT}
	donvidia ${NO_TLS_ROOT} ${usrpkglibdir}/libnvidia-tls.so ${sover}

	if ! use x86-fbsd; then
		donvidia ${TLS_ROOT} ${usrpkglibdir}/tls/libnvidia-tls.so ${sover}
	fi

	if want_tls ; then
		dosym ../tls/libnvidia-tls.so ${NV_ROOT}/lib
		dosym ../tls/libnvidia-tls.so.1 ${NV_ROOT}/lib
		dosym ../tls/libnvidia-tls.so.${sover} ${NV_ROOT}/lib
	else
		dosym ../no-tls/libnvidia-tls.so ${NV_ROOT}/lib
		dosym ../no-tls/libnvidia-tls.so.1 ${NV_ROOT}/lib
		dosym ../no-tls/libnvidia-tls.so.${sover} ${NV_ROOT}/lib
	fi

	if ! use x86-fbsd; then
		# Install the .la file for libtool, to prevent e.g. bug #176423
		[ -f "${FILESDIR}/libGL.la-r2" ] || die "libGL.la-r2 missing in FILESDIR"
		local ver1=$(get_version_component_range 1)
		local ver2=$(get_version_component_range 2)
		local ver3=$(get_version_component_range 3)
		sed -e "s:\${PV}:${PV}:"     \
			-e "s:\${ver1}:${ver1}:" \
			-e "s:\${ver2}:${ver2}:" \
			-e "s:\${ver3}:${ver3}:" \
			-e "s:\${libdir}:${inslibdir}:" \
			"${FILESDIR}"/libGL.la-r2 > "${D}"/${NV_ROOT}/lib/libGL.la
	fi

	exeinto ${X11_LIB_DIR}/modules/drivers

	[[ -f ${drvdir}/nvidia_drv.so ]] && \
		doexe ${drvdir}/nvidia_drv.so

	insinto /usr/${inslibdir}
	[[ -f ${libdir}/libXvMCNVIDIA.a ]] && \
		doins ${libdir}/libXvMCNVIDIA.a
	exeinto /usr/${inslibdir}
	# fix Bug 131315
	[[ -f ${libdir}/libXvMCNVIDIA.so.${PV} ]] && \
		doexe ${libdir}/libXvMCNVIDIA.so.${PV} && \
		dosym libXvMCNVIDIA.so.${PV} \
			/usr/${inslibdir}/libXvMCNVIDIA.so

	exeinto ${NV_ROOT}/extensions
	[[ -f ${libdir}/modules/libnvidia-wfb.so.${sover} ]] && \
		newexe ${libdir}/modules/libnvidia-wfb.so.${sover} libwfb.so
	[[ -f ${extdir}/libglx.so.${sover} ]] && \
		newexe ${extdir}/libglx.so.${sover} libglx.so

	# Includes
	insinto ${NV_ROOT}/include
	doins ${incdir}/*.h
}

pkg_preinst() {
	# Can we make up our minds ?!?!?
	local NV_D=${D}

	if ! has_version x11-base/xorg-server ; then
		for dir in lib lib32 lib64 ; do
			if [[ -d "${NV_D}/usr/${dir}/xorg" ]] ; then
				mv "${NV_D}/usr/${dir}"/xorg/* "${NV_D}/usr/${dir}"
				rmdir "${NV_D}/usr/${dir}/xorg"
			fi
		done
	fi

	# Clean the dynamic libGL stuff's home to ensure
	# we dont have stale libs floating around
	if [[ -d ${ROOT}/usr/lib/opengl/nvidia ]] ; then
		rm -rf "${ROOT}"/usr/lib/opengl/nvidia/*
	fi
	# Make sure we nuke the old nvidia-glx's env.d file
	if [[ -e ${ROOT}/etc/env.d/09nvidia ]] ; then
		rm -f "${ROOT}"/etc/env.d/09nvidia
	fi
}

pkg_postinst() {
	if ! use x86-fbsd; then
		linux-mod_pkg_postinst
	fi

	# Switch to the nvidia implementation
	eselect opengl set --use-old nvidia

	echo
	elog "To use the Nvidia GLX, run \"eselect opengl set nvidia\""
	elog
	elog "nVidia has requested that any bug reports submitted have the"
	elog "output of /usr/bin/nvidia-bug-report.sh included."
	elog
	elog "To work with compiz, you must enable the AddARGBGLXVisuals option."
	elog
	elog "If you are having resolution problems, try disabling DynamicTwinView."
	echo
}

want_tls() {
	# For uclibc or anything non glibc, return false
	has_version sys-libs/glibc || return 1

	# Old versions of glibc were lt/no-tls only
	has_version '<sys-libs/glibc-2.3.2' && return 1

	local valid_chost="true"
	if use x86 ; then
		case ${CHOST/-*} in
			i486|i586|i686) ;;
			*) valid_chost="false"
		esac
	fi

	[[ ${valid_chost} == "false" ]] && return 1

	# If we've got nptl, we've got tls
	built_with_use --missing true sys-libs/glibc nptl && return 0

	# 2.3.5 turned off tls for linuxthreads glibc on i486 and i586
	if use x86 && has_version '>=sys-libs/glibc-2.3.5' ; then
		case ${CHOST/-*} in
			i486|i586) return 1 ;;
		esac
	fi

	# These versions built linuxthreads version to support tls, too
	has_version '>=sys-libs/glibc-2.3.4.20040619-r2' && return 0

	return 1
}

pkg_postrm() {
	if ! use x86-fbsd; then
		linux-mod_pkg_postrm
	fi
	eselect opengl set --use-old xorg-x11
}
