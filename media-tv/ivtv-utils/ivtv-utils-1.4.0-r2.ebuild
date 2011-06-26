# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/ivtv-utils/ivtv-utils-1.4.0-r2.ebuild,v 1.6 2011/06/26 15:19:25 lxnay Exp $

EAPI=2

inherit eutils linux-mod linux-info toolchain-funcs

DESCRIPTION="IVTV utilities for Hauppauge PVR PCI cards"
HOMEPAGE="http://www.ivtvdriver.org"
SRC_URI="http://dl.ivtvdriver.org/ivtv/archive/1.4.x/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 ppc x86"
IUSE="perl"
RDEPEND=">=sys-fs/udev-103"
DEPEND="app-arch/unzip
	>=sys-kernel/linux-headers-2.6.29
	!media-tv/ivtv"
PDEPEND="|| ( >=media-tv/ivtv-firmware-20070217 sys-kernel/linux-firmware )
	perl? (
		dev-perl/Video-Frequencies
		dev-perl/Video-ivtv
		dev-perl/Config-IniFiles
		virtual/perl-Getopt-Long
		dev-perl/perl-tk )"

pkg_setup() {
	linux-info_pkg_setup

	### Commented out following line because it causes failure and because the module should already be in the kernel
	#       MODULE_NAMES="saa717x(extra:${S}/i2c-drivers)"
	BUILD_TARGETS="all"
	CONFIG_CHECK="~EXPERIMENTAL ~MODULES ~HAS_IOMEM ~FW_LOADER ~I2C ~I2C_ALGOBIT
		~VIDEO_DEV ~VIDEO_CAPTURE_DRIVERS ~VIDEO_V4L1 ~VIDEO_V4L2 ~VIDEO_IVTV"

	if ! ( kernel_is ge 2 6 29 ); then
		eerror "This package is only for the fully in-kernel"
		eerror "IVTV driver shipping with kernel 2.6.29 or newer"
		eerror ""
		eerror "You will need to either:"
		eerror "a) emerge a 2.6.29 or newer kernel"
		eerror "b) emerge media-tv/ivtv or media-tv/ivtv-utils for"
		eerror "your kernel"
		eerror ""
		eerror "See http://ivtvdriver.org/ for more information"
		die "This only works on 2.6.29 or newer kernels"
	fi

	ewarn "Make sure that your I2C and V4L kernel drivers are loaded as"
	ewarn "modules, and not compiled into the kernel, or IVTV will not"
	ewarn "work."

	linux-mod_pkg_setup

	BUILD_PARAMS="KDIR=${KV_DIR}"
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-gentoo.patch
}

src_compile() {
	tc-export CC CXX
	emake || die
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install || die "failed to install"
	dodoc README doc/* ChangeLog || die
	if use perl; then
		dobin utils/perl/*.pl || die
		dodoc utils/perl/README.ptune || die
	fi
}

pkg_postinst() {
	linux-mod_pkg_postinst

	elog ""
	elog "This version of the IVTV utils supports hardware listed at:"
	elog "http://www.ivtvdriver.org/index.php/Supported_hardware"
	ewarn ""
	ewarn "IMPORTANT: In case of problems first read the following:"
	ewarn "http://www.ivtvdriver.org/index.php/Troubleshooting"
	ewarn "/usr/share/doc/${PF}/README.*"
	ewarn ""
	ewarn " - Using MythTV, a PVR-350 and the ivtvfb module"
	ewarn " - Using the ivtv X driver and the ivtvfb module"
	ewarn " - You want to manually build ivtv against v4l-dvb"
	ewarn ""
	ewarn "Also, the ivtv package comes with lots of documentation regarding "
	ewarn "setup, proper use and debugging utilities."
	ewarn "They are also located in /usr/share/doc/${PF}/"
	ewarn ""
	elog "For more information, see the IVTV driver homepage at:"
	elog "http://www.ivtvdriver.org/"
}
