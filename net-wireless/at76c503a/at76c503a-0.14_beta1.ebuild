# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/at76c503a/at76c503a-0.13.ebuild,v 1.1 2006/06/26 16:18:44 genstef Exp $

inherit linux-mod

MY_P=at76_usb-${PV/_}
DESCRIPTION="at76c503 is a Linux driver for the wlan USB adapter based on the Atmel at76c503 chip. It currently supports ad-hoc mode, infrastructure mode, and WEP. It supports adapters from Atmel, the Belkin F5D6050, Netgear MA101, and others."
HOMEPAGE="http://developer.berlios.de/projects/at76c503a/"
SRC_URI="http://download.berlios.de/at76c503a/${MY_P}.tar.gz"
#http://prdownload.berlios.de/at76c503a/at76_usb-0.14beta1.tar.gz
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
RDEPEND="net-wireless/atmel-firmware
		>=sys-apps/hotplug-20040923
		>=net-wireless/wireless-tools-26-r1"
S=${WORKDIR}/${MY_P}

MODULE_NAMES="at76_usb(net:)"
BUILD_TARGETS="all"

CONFIG_CHECK="NET_RADIO"
NET_RADIO_ERROR="${P} requires support for Wireless LAN drivers (non-hamradio) & Wireless Extensions (CONFIG_NET_RADIO)."

pkg_setup() {
	
	linux-mod_pkg_setup
	BUILD_PARAMS="KSRC=${KV_DIR} KERNEL_DIR=${KV_DIR}"
}

src_install() {
	linux-mod_src_install

	dodoc README CHANGELOG
}
