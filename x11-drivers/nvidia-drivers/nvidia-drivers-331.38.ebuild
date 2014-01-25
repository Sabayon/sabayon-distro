# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic linux-info linux-mod multilib nvidia-driver \
	portability toolchain-funcs unpacker user

NV_URI="http://us.download.nvidia.com/XFree86/"
X86_NV_PACKAGE="NVIDIA-Linux-x86-${PV}"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"
X86_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86-${PV}"
AMD64_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86_64-${PV}"

DESCRIPTION="NVIDIA GPUs kernel drivers"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="
	amd64-fbsd? ( ${NV_URI}FreeBSD-x86_64/${PV}/${AMD64_FBSD_NV_PACKAGE}.tar.gz )
	amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}.run )
	x86-fbsd? ( ${NV_URI}FreeBSD-x86/${PV}/${X86_FBSD_NV_PACKAGE}.tar.gz )
	x86? ( ${NV_URI}Linux-x86/${PV}/${X86_NV_PACKAGE}.run )
"

LICENSE="NVIDIA-r1"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="acpi custom-cflags multilib x-multilib kernel_FreeBSD kernel_linux pax_kernel tools X"
RESTRICT="bindist mirror strip"

DEPEND="kernel_linux? ( virtual/linux-sources )"
RDEPEND="~x11-drivers/nvidia-userspace-${PV}
	x-multilib? ( ~x11-drivers/nvidia-userspace-${PV}[x-multilib] )
	multilib? ( ~x11-drivers/nvidia-userspace-${PV}[multilib] )
	~x11-drivers/nvidia-userspace-${PV}[tools=]
	~x11-drivers/nvidia-userspace-${PV}[X=]"
PDEPEND=""

S=${WORKDIR}/

pkg_pretend() {
	# Since Nvidia ships 3 different series of drivers, we need to give the user
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

pkg_setup() {
	# try to turn off distcc and ccache for people that have a problem with it
	export DISTCC_DISABLE=1
	export CCACHE_DISABLE=1

	if use kernel_linux; then
		linux-mod_pkg_setup
		MODULE_NAMES="nvidia(video:${S}/kernel)"
		BUILD_PARAMS="IGNORE_CC_MISMATCH=yes V=1 SYSSRC=${KV_DIR} \
		SYSOUT=${KV_OUT_DIR} CC=$(tc-getBUILD_CC)"
		# linux-mod_src_compile calls set_arch_to_kernel, which
		# sets the ARCH to x86 but NVIDIA's wrapping Makefile
		# expects x86_64 or i386 and then converts it to x86
		# later on in the build process
		BUILD_FIXES="ARCH=$(uname -m | sed -e 's/i.86/i386/')"
	fi

	# set variables to where files are in the package structure
	if use kernel_FreeBSD; then
		use x86-fbsd   && S="${WORKDIR}/${X86_FBSD_NV_PACKAGE}"
		use amd64-fbsd && S="${WORKDIR}/${AMD64_FBSD_NV_PACKAGE}"
		NV_SRC="${S}/src"
		NV_SOVER=1
	elif use kernel_linux; then
		NV_SRC="${S}/kernel"
		NV_SOVER=${PV}
	else
		die "Could not determine proper NVIDIA package"
	fi
}

src_unpack() {
	if ! use kernel_FreeBSD; then
		cd "${S}"
		unpack_makeself
	else
		unpack ${A}
	fi
}

src_prepare() {
	# Please add a brief description for every added patch

	if use kernel_linux; then
		if kernel_is lt 2 6 9 ; then
			eerror "You must build this against 2.6.9 or higher kernels."
		fi

		# If greater than 2.6.5 use M= instead of SUBDIR=
#		convert_to_m "${NV_SRC}"/Makefile.kbuild
	fi
	if use pax_kernel; then
		ewarn "Using PAX patches is not supported. You will be asked to"
		ewarn "use a standard kernel should you have issues. Should you"
		ewarn "need support with these patches, contact the PaX team."
		epatch "${FILESDIR}"/${P}-pax-usercopy.patch
	fi

	# Allow user patches so they can support RC kernels and whatever else
	epatch_user
}

src_compile() {
	# This is already the default on Linux, as there's no toplevel Makefile, but
	# on FreeBSD there's one and triggers the kernel module build, as we install
	# it by itself, pass this.

	cd "${NV_SRC}"
	if use kernel_FreeBSD; then
		MAKE="$(get_bmake)" CFLAGS="-Wno-sign-compare" emake CC="$(tc-getCC)" \
			LD="$(tc-getLD)" LDFLAGS="$(raw-ldflags)" || die
	elif use kernel_linux; then
		linux-mod_src_compile
	fi
}

src_install() {
	if use kernel_linux; then
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
	use kernel_linux && linux-mod_pkg_preinst
}

pkg_postinst() {
	use kernel_linux && linux-mod_pkg_postinst

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
	use kernel_linux && linux-mod_pkg_postrm
}
