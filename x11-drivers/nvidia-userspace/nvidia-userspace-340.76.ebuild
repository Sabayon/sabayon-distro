# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic linux-info linux-mod multilib nvidia-driver \
	portability toolchain-funcs unpacker user udev

NV_URI="http://us.download.nvidia.com/XFree86/"
X86_NV_PACKAGE="NVIDIA-Linux-x86-${PV}"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"
X86_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86-${PV}"
AMD64_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86_64-${PV}"

DESCRIPTION="NVIDIA X11 userspace libraries and applications"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="
	amd64-fbsd? ( ${NV_URI}FreeBSD-x86_64/${PV}/${AMD64_FBSD_NV_PACKAGE}.tar.gz )
	amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}.run )
	x86-fbsd? ( ${NV_URI}FreeBSD-x86/${PV}/${X86_FBSD_NV_PACKAGE}.tar.gz )
	x86? ( ${NV_URI}Linux-x86/${PV}/${X86_NV_PACKAGE}.run )
"

LICENSE="GPL-2 NVIDIA-r1"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="acpi multilib x-multilib kernel_FreeBSD kernel_linux tools +X uvm"
RESTRICT="bindist mirror strip"
EMULTILIB_PKG="true"

COMMON="app-eselect/eselect-opencl
	kernel_linux? ( >=sys-libs/glibc-2.6.1 )
	x-multilib? (
		|| (
			 (
				x11-libs/libX11[abi_x86_32]
				x11-libs/libXext[abi_x86_32]
			 )
			app-emulation/emul-linux-x86-xlibs
		)
	)
	multilib? ( app-emulation/emul-linux-x86-baselibs )
	X? (
		>=app-eselect/eselect-opengl-1.0.9
	)"
DEPEND="${COMMON}"
# Note: do not add !>nvidia-userspace-ver or !<nvidia-userspace-ver
# because it would cause pkg_postrm to set the wrong opengl implementation
RDEPEND="${COMMON}
	X? ( x11-libs/libXvMC )
	acpi? ( sys-power/acpid )
	tools? ( media-video/nvidia-settings )"
PDEPEND="X? (
		<x11-base/xorg-server-1.16.99
		>=x11-libs/libvdpau-0.3-r1
	)"

REQUIRED_USE="tools? ( X )"
QA_PREBUILT="opt/* usr/lib*"
S=${WORKDIR}/

pkg_pretend() {
	if use amd64 && has_multilib_profile && \
		[ "${DEFAULT_ABI}" != "amd64" ]; then
		eerror "This ebuild doesn't currently support changing your default ABI"
		die "Unexpected \${DEFAULT_ABI} = ${DEFAULT_ABI}"
	fi
}

pkg_setup() {
	# try to turn off distcc and ccache for people that have a problem with it
	export DISTCC_DISABLE=1
	export CCACHE_DISABLE=1

	# set variables to where files are in the package structure
	if use kernel_FreeBSD; then
		use x86-fbsd   && S="${WORKDIR}/${X86_FBSD_NV_PACKAGE}"
		use amd64-fbsd && S="${WORKDIR}/${AMD64_FBSD_NV_PACKAGE}"
		NV_DOC="${S}/doc"
		NV_OBJ="${S}/obj"
		NV_SRC="${S}/src"
		NV_MAN="${S}/x11/man"
		NV_X11="${S}/obj"
		NV_SOVER=1
	elif use kernel_linux; then
		NV_DOC="${S}"
		NV_OBJ="${S}"
		NV_SRC="${S}/kernel"
		NV_MAN="${S}"
		NV_X11="${S}"
		NV_SOVER=${PV}
	else
		die "Could not determine proper NVIDIA package"
	fi
}

src_prepare() {
	# Please add a brief description for every added patch

	# Allow user patches so they can support RC kernels and whatever else
	epatch_user
}

src_compile() { :; }

# Install nvidia library:
# the first parameter is the library to install
# the second parameter is the provided soversion
# the third parameter is the target directory if its not /usr/lib
donvidia() {
	# Full path to library minus SOVER
	MY_LIB="$1"

	# SOVER to use
	MY_SOVER="$2"

	# Where to install
	MY_DEST="$3"

	if [[ -z "${MY_DEST}" ]]; then
		MY_DEST="/usr/$(get_libdir)"
		action="dolib.so"
	else
		exeinto ${MY_DEST}
		action="doexe"
	fi

	# Get just the library name
	libname=$(basename $1)

	# Install the library with the correct SOVER
	${action} ${MY_LIB}.${MY_SOVER} || \
		die "failed to install ${libname}"

	# If SOVER wasn't 1, then we need to create a .1 symlink
	if [[ "${MY_SOVER}" != "1" ]]; then
		dosym ${libname}.${MY_SOVER} \
			${MY_DEST}/${libname}.1 || \
			die "failed to create ${libname} symlink"
	fi

	# Always create the symlink from the raw lib to the .1
	dosym ${libname}.1 \
		${MY_DEST}/${libname} || \
		die "failed to create ${libname} symlink"
}

src_install() {
	if use kernel_linux; then
		# Add the aliases
		# This file is tweaked with the appropriate video group in
		# pkg_preinst, see bug #491414
		insinto /etc/modprobe.d
		newins "${FILESDIR}"/nvidia-169.07 nvidia.conf
		use uvm && doins "${FILESDIR}"/nvidia-uvm.conf

		# Ensures that our device nodes are created when not using X
		exeinto "$(get_udevdir)"
		doexe "${FILESDIR}"/nvidia-udev.sh
		udev_newrules "${FILESDIR}"/nvidia.udev-rule 99-nvidia.rules
	elif use kernel_FreeBSD; then
		if use x86-fbsd; then
			insinto /boot/modules
			doins "${S}/src/nvidia.kld"
		fi

		exeinto /boot/modules
		doexe "${S}/src/nvidia.ko"
	fi

	# NVIDIA kernel <-> userspace driver config lib
	donvidia ${NV_OBJ}/libnvidia-cfg.so ${NV_SOVER}

	# NVIDIA framebuffer capture library
	donvidia ${NV_OBJ}/libnvidia-fbc.so ${NV_SOVER}

	# NVIDIA video encode/decode <-> CUDA
	if use kernel_linux; then
		donvidia ${NV_OBJ}/libnvcuvid.so ${NV_SOVER}
		donvidia ${NV_OBJ}/libnvidia-encode.so ${NV_SOVER}
	fi

	if use X; then
		# Xorg DDX driver
		insinto /usr/$(get_libdir)/xorg/modules/drivers
		doins ${NV_X11}/nvidia_drv.so

		# Xorg GLX driver
		donvidia ${NV_X11}/libglx.so ${NV_SOVER} \
			/usr/$(get_libdir)/opengl/nvidia/extensions
	fi

	# OpenCL ICD for NVIDIA
	if use kernel_linux; then
		insinto /etc/OpenCL/vendors
		doins ${NV_OBJ}/nvidia.icd
	fi

	# Documentation
	dohtml ${NV_DOC}/html/*
	if use kernel_FreeBSD; then
		dodoc "${NV_DOC}/README"
		use X && doman "${NV_MAN}/nvidia-xconfig.1"
	else
		# Docs
		newdoc "${NV_DOC}/README.txt" README
		dodoc "${NV_DOC}/NVIDIA_Changelog"
		doman "${NV_MAN}/nvidia-smi.1.gz"
		doman "${NV_MAN}/nvidia-cuda-mps-control.1.gz"
		use X && doman "${NV_MAN}/nvidia-xconfig.1.gz"
	fi

	# Helper Apps
	exeinto /opt/bin/
	if use X; then
		doexe ${NV_OBJ}/nvidia-xconfig
	fi

	if use kernel_linux ; then
		doexe ${NV_OBJ}/nvidia-cuda-mps-control
		doexe ${NV_OBJ}/nvidia-cuda-mps-server
		doexe ${NV_OBJ}/nvidia-debugdump
		doexe ${NV_OBJ}/nvidia-persistenced
		doexe ${NV_OBJ}/nvidia-smi

		# install nvidia-modprobe setuid and symlink in /usr/bin (bug #505092)
		doexe ${NV_OBJ}/nvidia-modprobe
		fowners root:video /opt/bin/nvidia-modprobe
		fperms 4710 /opt/bin/nvidia-modprobe
		dosym /{opt,usr}/bin/nvidia-modprobe

		doman nvidia-cuda-mps-control.1.gz
		doman nvidia-modprobe.1.gz
		doman nvidia-persistenced.1.gz
		newinitd "${FILESDIR}/nvidia-smi.init" nvidia-smi
	fi

	exeinto /usr/bin/
	doexe ${NV_OBJ}/nvidia-bug-report.sh

	if has_multilib_profile && use multilib ; then
		local OABI=${ABI}
		for ABI in $(get_install_abis) ; do
			src_install-libs
		done
		ABI=${OABI}
		unset OABI
	else
		src_install-libs
	fi

	is_final_abi || die "failed to iterate through all ABIs"

	readme.gentoo_create_doc
}

src_install-libs() {
	local inslibdir=$(get_libdir)
	local GL_ROOT="/usr/$(get_libdir)/opengl/nvidia/lib"
	local CL_ROOT="/usr/$(get_libdir)/OpenCL/vendors/nvidia"
	local libdir=${NV_OBJ}

	if use kernel_linux && has_multilib_profile && \
			[[ ${ABI} == "x86" ]] ; then
		libdir=${NV_OBJ}/32
	fi

	if use X; then
		# The GLX libraries
		donvidia ${libdir}/libEGL.so ${NV_SOVER} ${GL_ROOT}
		donvidia ${libdir}/libGL.so ${NV_SOVER} ${GL_ROOT}
		donvidia ${libdir}/libGLESv1_CM.so ${NV_SOVER} ${GL_ROOT}
		donvidia ${libdir}/libnvidia-eglcore.so ${NV_SOVER}
		donvidia ${libdir}/libnvidia-glcore.so ${NV_SOVER}
		donvidia ${libdir}/libnvidia-glsi.so ${NV_SOVER}
		donvidia ${libdir}/libnvidia-ifr.so ${NV_SOVER}
		if use kernel_FreeBSD; then
			donvidia ${libdir}/libnvidia-tls.so ${NV_SOVER}
		else
			donvidia ${libdir}/tls/libnvidia-tls.so ${NV_SOVER}
		fi

		# VDPAU
		donvidia ${libdir}/libvdpau_nvidia.so ${NV_SOVER}

		# GLES v2 libraries
		insinto ${GL_ROOT}
		doexe ${libdir}/libGLESv2.so.${PV}
		dosym libGLESv2.so.${PV} ${GL_ROOT}/libGLESv2.so.2
		dosym libGLESv2.so.2 ${GL_ROOT}/libGLESv2.so
	fi

	# NVIDIA monitoring library
	if use kernel_linux ; then
		donvidia ${libdir}/libnvidia-ml.so ${NV_SOVER}
	fi

	# CUDA & OpenCL
	if use kernel_linux; then
		donvidia ${libdir}/libcuda.so ${NV_SOVER}
		donvidia ${libdir}/libnvidia-compiler.so ${NV_SOVER}
		donvidia ${libdir}/libOpenCL.so 1.0.0 ${CL_ROOT}
		donvidia ${libdir}/libnvidia-opencl.so ${NV_SOVER}
	fi
}

pkg_preinst() {
	# Clean the dynamic libGL stuff's home to ensure
	# we dont have stale libs floating around
	if [ -d "${ROOT}"/usr/lib/opengl/nvidia ] ; then
		rm -rf "${ROOT}"/usr/lib/opengl/nvidia/*
	fi
	# Make sure we nuke the old nvidia-glx's env.d file
	if [ -e "${ROOT}"/etc/env.d/09nvidia ] ; then
		rm -f "${ROOT}"/etc/env.d/09nvidia
	fi

	local videogroup="$(getent group video | cut -d ':' -f 3)"
	if [ -n "${videogroup}" ]; then
		sed -i -e "s:PACKAGE:${PF}:g" \
			-e "s:VIDEOGID:${videogroup}:" "${ROOT}"/etc/modprobe.d/nvidia.conf
	else
		eerror "Failed to determine the video group gid."
		die "Failed to determine the video group gid."
	fi
}

pkg_postinst() {
	# Switch to the nvidia implementation
	use X && "${ROOT}"/usr/bin/eselect opengl set --use-old nvidia
	"${ROOT}"/usr/bin/eselect opencl set --use-old nvidia

	readme.gentoo_print_elog

	if ! use X; then
		elog "You have elected to not install the X.org driver. Along with"
		elog "this the OpenGL libraries and VDPAU libraries were not"
		elog "installed. Additionally, once the driver is loaded your card"
		elog "and fan will run at max speed which may not be desirable."
		elog "Use the 'nvidia-smi' init script to have your card and fan"
		elog "speed scale appropriately."
		elog
	fi
}

pkg_prerm() {
	use X && "${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
}

pkg_postrm() {
	use X && "${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
}
