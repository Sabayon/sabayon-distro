# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/ivtv/ivtv-0.9.1.ebuild,v 1.4 2007/02/01 17:09:41 beandog Exp $

inherit eutils linux-mod

DESCRIPTION="ivtv driver for Hauppauge PVR PCI cards"
HOMEPAGE="http://www.ivtvdriver.org"
SRC_URI="http://dl.ivtvdriver.org/ivtv/unstable/${P/_/}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc x86"
IUSE="fbcon"

RDEPEND="|| ( >=sys-fs/udev-103 sys-apps/hotplug )"
DEPEND="app-arch/unzip"
PDEPEND="media-tv/pvr-firmware"

pkg_setup() {

	MODULE_NAMES="ivtv(extra:${S}/driver)
			saa717x(extra:${S}/i2c-drivers)"
	BUILD_TARGETS="all"
	CONFIG_CHECK="EXPERIMENTAL KMOD VIDEO_DEV I2C VIDEO_V4L1_COMPAT VIDEO_V4L2
		!VIDEO_HELPER_CHIPS_AUTO
		FW_LOADER VIDEO_WM8775 VIDEO_MSP3400 VIDEO_CX25840 VIDEO_TUNER
		VIDEO_SAA711X VIDEO_CX2341X VIDEO_SAA7127 VIDEO_TVEEPROM"

	if use fbcon; then
		MODULE_NAMES="${MODULE_NAMES} ivtv-fb(extra:${S}/driver)"
		CONFIG_CHECK="${CONFIG_CHECK} FB"
	fi

	if ! kernel_is 2 6 20; then
		eerror "Each IVTV driver branch will only work with a specific"
		eerror "linux kernel branch."
		eerror ""
		eerror "You will need to either:"
		eerror "a) emerge a different kernel"
		eerror "b) emerge a different driver"
		eerror ""
		eerror "ivtv branch <--> kernel branch"
		eerror "0.10.x w/patches <--> 2.6.20.x"
		eerror "0.9.x <--> 2.6.19.x"
		eerror "0.8.x <--> 2.6.18.x"
		eerror "0.7.x <--> 2.6.17.x"
		eerror "0.6.x <--> 2.6.16.x"
		eerror "0.4.x <--> 2.6.15.x"
		eerror ""
		eerror "See http://ivtvdriver.org/ for more information"
		die "This only works on 2.6.19 kernels"
	fi

	linux-mod_pkg_setup

	BUILD_PARAMS="KDIR=${KV_DIR}"
}

src_unpack() {
	linux-mod_src_unpack

	cd ${S}
	epatch ${FILESDIR}/${PN}-2.6.20.patch	
}

src_compile() {

	cd "${S}/driver"
	linux-mod_src_compile || die "failed to build driver"

	cd "${S}/utils"
	emake INCDIR="${KV_DIR}/include" || die "failed to build utils "
}

src_install() {
	cd "${S}/utils"
	make DESTDIR="${D}" PREFIX="/usr" install || die "failed to install utils"

	cd "${S}"
	dodoc README doc/* utils/README.X11

	cd "${S}/driver"
	linux-mod_src_install || die "failed to install modules"

	# Add the aliases
	insinto /etc/modules.d
	newins "${FILESDIR}"/ivtv ivtv
}
