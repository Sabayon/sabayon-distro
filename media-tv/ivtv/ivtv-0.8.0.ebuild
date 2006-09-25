# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/ivtv/ivtv-0.7.0.ebuild,v 1.4 2006/07/22 22:44:24 cardoe Exp $

inherit eutils linux-mod

DESCRIPTION="ivtv driver for Hauppauge PVR PCI cards"
HOMEPAGE="http://www.ivtvdriver.org"

FW_VER_DEC="pvr_1.18.21.22254_inf.zip"
FW_VER_ENC="pvr_2.0.43.24103_whql.zip"
#Switched to recommended firmware by driver

SRC_URI="http://dl.ivtvdriver.org/ivtv/archive/0.8.x/${P}.tar.gz
	ftp://ftp.shspvr.com/download/wintv-pvr_150-500/inf/${FW_VER_ENC}
	ftp://ftp.shspvr.com/download/wintv-pvr_250-350/inf/${FW_VER_DEC}"

RESTRICT="nomirror"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~ppc"

IUSE=""

BUILD_TARGETS="all"
BUILD_PARAMS="KDIR=${KERNEL_DIR}"

RDEPEND="sys-apps/hotplug"
DEPEND="app-arch/unzip"

pkg_setup() {
	linux-mod_pkg_setup
	MODULE_NAMES="ivtv(extra:${S}/driver) \
			saa717x(extra:${S}/i2c-drivers)"

	if kernel_is 2 6 18; then
		CONFIG_CHECK="EXPERIMENTAL VIDEO_DEV I2C VIDEO_V4L1 VIDEO_V4L2 FW_LOADER"
		CONFIG_CHECK="${CONFIG_CHECK} VIDEO_WM8775 VIDEO_MSP3400 VIDEO_CX25840 VIDEO_TUNER"
		CONFIG_CHECK="${CONFIG_CHECK} VIDEO_SAA711X VIDEO_SAA7127 VIDEO_TVEEPROM"
	else
		die "This only works on 2.6.18 kernels"
	fi

	linux_chkconfig_present FB && \
	MODULE_NAMES="${MODULE_NAMES} ivtv-fb(extra:${S}/driver)"

	linux-mod_pkg_setup
}

src_unpack() {
	unpack ${P}.tar.gz
	unpack ${FW_VER_ENC}

	cd ${S}
	sed -e "s:^VERS26=.*:VERS26=${KV_MAJOR}.${KV_MINOR}:g" \
		-i ${S}/driver/Makefile || die "sed failed"
}

src_compile() {
	cd ${S}/driver
	linux-mod_src_compile || die "failed to build driver "

	cd ${S}/utils
	emake ||  die "failed to build utils "
}

src_install() {
	cd ${S}/utils
	dodir /lib/firmware
	./ivtvfwextract.pl "${DISTDIR}"/${FW_VER_DEC} \
		"${D}"/lib/firmware/v4l-cx2341x-enc.fw \
		"${D}"/lib/firmware/v4l-cx2341x-dec.fw

	make KERNELDIR="${KERNEL_DIR}" DESTDIR="${D}" PREFIX=/usr install || die "failed to install"

	insinto /lib/firmware
	newins "${WORKDIR}"/DriverA2/HcwMakoC.ROM v4l-cx25840.fw
	newins ${S}/v4l-cx2341x-init.mpg v4l-cx2341x-init.mpg

	cd ${S}
	dodoc README doc/* utils/README.X11

	cd ${S}/driver
	linux-mod_src_install || die "failed to install modules"

	# Add the aliases
	insinto /etc/modules.d
	newins "${FILESDIR}"/ivtv ivtv
}
