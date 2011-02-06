# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2

BC_REVISION="4"
DESCRIPTION="Firmware for the BCM43xx Broadcom adapters using mac80211 driver"
HOMEPAGE="http://bcm43xx.berlios.de/"
SRC_URI="mirror://sabayon/net-wireless/bcm43xx-firmware/bcm-${PV}-${BC_REVISION}.tar.bz2"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"

pkg_preinst() {
	ewarn "This firmware is suitable ONLY for mac80211 Broadcom driver"
	ewarn "DO NOT USE THIS IF YOU DON'T KNOW WHAT YOU ARE DOING !!!!!!"
	sleep 10
}

src_install() {
	cd ${WORKDIR}/bcm-${PV}-${BC_REVISION}
	insinto /lib/firmware
	doins *.fw
}
