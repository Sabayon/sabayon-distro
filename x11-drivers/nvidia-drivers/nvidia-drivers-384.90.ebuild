# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils flag-o-matic linux-info linux-mod multilib nvidia-driver \
	portability toolchain-funcs unpacker user udev

NV_URI="http://us.download.nvidia.com/XFree86/"
X86_NV_PACKAGE="NVIDIA-Linux-x86-${PV}"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"
ARM_NV_PACKAGE="NVIDIA-Linux-armv7l-gnueabihf-${PV}"
X86_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86-${PV}"
AMD64_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86_64-${PV}"

DESCRIPTION="NVIDIA X11 userspace libraries and applications"
HOMEPAGE="http://www.nvidia.com/ http://www.nvidia.com/Download/Find.aspx"
SRC_URI="
	amd64-fbsd? ( ${NV_URI}FreeBSD-x86_64/${PV}/${AMD64_FBSD_NV_PACKAGE}.tar.gz )
	amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}.run )
	arm? ( ${NV_URI}Linux-x86-ARM/${PV}/${ARM_NV_PACKAGE}.run )
	x86-fbsd? ( ${NV_URI}FreeBSD-x86/${PV}/${X86_FBSD_NV_PACKAGE}.tar.gz )
	x86? ( ${NV_URI}Linux-x86/${PV}/${X86_NV_PACKAGE}.run )
"

LICENSE="GPL-2 NVIDIA-r2"
SLOT="0/${PV%.*}"
KEYWORDS="-* ~amd64 ~x86 ~amd64-fbsd ~x86-fbsd"
RESTRICT="bindist mirror"
EMULTILIB_PKG="true"

IUSE="acpi compat +driver gtk3 kernel_FreeBSD kernel_linux +kms multilib pax_kernel static-libs +tools uvm wayland +X x-multilib"
REQUIRED_USE="
	tools? ( X )
	static-libs? ( tools )
"

COMMON="
	app-eselect/eselect-opencl
	kernel_linux? ( >=sys-libs/glibc-2.6.1 )
	X? (
		>=app-eselect/eselect-opengl-1.0.9
		app-misc/pax-utils
	)
"
DEPEND="
	${COMMON}
	app-arch/xz-utils
	kernel_linux? ( virtual/linux-sources )
"
RDEPEND="
	${COMMON}
	acpi? ( sys-power/acpid )
	wayland? ( dev-libs/wayland )
	X? (
		<x11-base/xorg-server-1.19.99:=
		>=x11-libs/libvdpau-1.0
		multilib? (
			>=x11-libs/libX11-1.6.2[abi_x86_32]
			>=x11-libs/libXext-1.3.2[abi_x86_32]
		)
	)
	~x11-drivers/nvidia-userspace-${PV}
	x-multilib? ( ~x11-drivers/nvidia-userspace-${PV}[x-multilib] )
	multilib? ( ~x11-drivers/nvidia-userspace-${PV}[multilib] )
	~x11-drivers/nvidia-userspace-${PV}[tools=]
	~x11-drivers/nvidia-userspace-${PV}[X=]
"

QA_PREBUILT="opt/* usr/lib*"

S=${WORKDIR}/

nvidia_drivers_versions_check() {
	if use amd64 && has_multilib_profile && \
		[ "${DEFAULT_ABI}" != "amd64" ]; then
		eerror "This ebuild doesn't currently support changing your default ABI"
		die "Unexpected \${DEFAULT_ABI} = ${DEFAULT_ABI}"
	fi

	if use kernel_linux && kernel_is ge 4 14; then
		ewarn "Gentoo supports kernels which are supported by NVIDIA"
		ewarn "which are limited to the following kernels:"
		ewarn "<sys-kernel/linux-sabayon-4.14"
		ewarn ""
		ewarn "You are free to utilize epatch_user to provide whatever"
		ewarn "support you feel is appropriate, but will not receive"
		ewarn "support as a result of those changes."
		ewarn ""
		ewarn "Do not file a bug report about this."
		ewarn ""
	fi

	# Since Nvidia ships many different series of drivers, we need to give the user
	# some kind of guidance as to what version they should install. This tries
	# to point the user in the right direction but can't be perfect. check
	# nvidia-driver.eclass
	nvidia-driver-check-warning

	# Kernel features/options to check for
	CONFIG_CHECK="~ZONE_DMA ~MTRR ~SYSVIPC ~!LOCKDEP"
	use x86 && CONFIG_CHECK+=" ~HIGHMEM"

	# Now do the above checks
	use kernel_linux && check_extra_config
}

pkg_pretend() {
	nvidia_drivers_versions_check
}

pkg_setup() {
	nvidia_drivers_versions_check

	# try to turn off distcc and ccache for people that have a problem with it
	export DISTCC_DISABLE=1
	export CCACHE_DISABLE=1

	if use driver && use kernel_linux; then
		MODULE_NAMES="nvidia(video:${S}/kernel)"
		use uvm && MODULE_NAMES+=" nvidia-uvm(video:${S}/kernel)"
		use kms && MODULE_NAMES+=" nvidia-modeset(video:${S}/kernel) nvidia-drm(video:${S}/kernel)"

		# This needs to run after MODULE_NAMES (so that the eclass checks
		# whether the kernel supports loadable modules) but before BUILD_PARAMS
		# is set (so that KV_DIR is populated).
		linux-mod_pkg_setup

		BUILD_PARAMS="IGNORE_CC_MISMATCH=yes V=1 SYSSRC=${KV_DIR} \
		SYSOUT=${KV_OUT_DIR} CC=$(tc-getBUILD_CC) NV_VERBOSE=1"

		# linux-mod_src_compile calls set_arch_to_kernel, which
		# sets the ARCH to x86 but NVIDIA's wrapping Makefile
		# expects x86_64 or i386 and then converts it to x86
		# later on in the build process
		BUILD_FIXES="ARCH=$(uname -m | sed -e 's/i.86/i386/')"
	fi

	if use kernel_linux && kernel_is lt 2 6 9; then
		eerror "You must build this against 2.6.9 or higher kernels."
	fi

	# set variables to where files are in the package structure
	if use kernel_FreeBSD; then
		use x86-fbsd   && S="${WORKDIR}/${X86_FBSD_NV_PACKAGE}"
		use amd64-fbsd && S="${WORKDIR}/${AMD64_FBSD_NV_PACKAGE}"
		NV_OBJ="${S}/obj"
		NV_SRC="${S}/src"
		NV_X11="${S}/obj"
		NV_SOVER=1
	elif use kernel_linux; then
		NV_OBJ="${S}"
		NV_SRC="${S}/kernel"
		NV_X11="${S}"
		NV_SOVER=${PV}
	else
		die "Could not determine proper NVIDIA package"
	fi
}

src_prepare() {
	if use pax_kernel; then
		ewarn "Using PAX patches is not supported. You will be asked to"
		ewarn "use a standard kernel should you have issues. Should you"
		ewarn "need support with these patches, contact the PaX team."
		eapply "${FILESDIR}"/${PN}-375.20-pax.patch
	fi

	# Allow user patches so they can support RC kernels and whatever else
	eapply_user
}

src_compile() {
	# This is already the default on Linux, as there's no toplevel Makefile, but
	# on FreeBSD there's one and triggers the kernel module build, as we install
	# it by itself, pass this.

	cd "${NV_SRC}"
	if use kernel_FreeBSD; then
		MAKE="$(get_bmake)" CFLAGS="-Wno-sign-compare" emake CC="$(tc-getCC)" \
			LD="$(tc-getLD)" LDFLAGS="$(raw-ldflags)" || die
	elif use driver && use kernel_linux; then
		MAKEOPTS=-j1 linux-mod_src_compile
	fi
}

src_install() {
	if use driver && use kernel_linux; then
		linux-mod_src_install
	elif use kernel_FreeBSD; then
		if use x86-fbsd; then
			insinto /boot/modules
			doins "${S}/src/nvidia.kld"
		fi

		exeinto /boot/modules
		doexe "${S}/src/nvidia.ko"
	fi

	is_final_abi || die "failed to iterate through all ABIs"
}

pkg_preinst() {
	if use driver && use kernel_linux; then
		linux-mod_pkg_preinst
	fi
}

pkg_postinst() {
	use driver && use kernel_linux && linux-mod_pkg_postinst

	echo
	elog "You must be in the video group to use the NVIDIA device"
	elog "For more info, read the docs at"
	elog "http://www.gentoo.org/doc/en/nvidia-guide.xml#doc_chap3_sect6"
	elog

	elog "This package installs a kernel module and X driver. Both must"
	elog "match explicitly in their version. This means, if you restart"
	elog "X, you must modprobe -r nvidia before starting it back up"
	elog

}

pkg_postrm() {
	use driver && use kernel_linux && linux-mod_pkg_postrm
}
