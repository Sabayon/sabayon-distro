# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Firmware for the new b43 b43-legacy drivers for Broadcom wireless adapters using mac80211 driver"
HOMEPAGE="http://bcm43xx.berlios.de/"
SRC_URI="http://www.sabayonlinux.org/distfiles/net-wireless/b43-firmware/b43-firmware-${PV}.tar.bz2"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"
S="${WORKDIR}/${PV}"
pkg_preinst() {
	ewarn "This firmware is suitable ONLY for mac80211 Broadcom driver"
	ewarn "DO NOT USE THIS IF YOU DON'T KNOW WHAT YOU ARE DOING !!!!!!"
	sleep 10
}

src_install() {
	cd ${S}/
	insinto /lib/firmware
	doins -r *
}
