# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

BC_REVISION="1"
DESCRIPTION="Firmware for the BCM43xx Broadcom adapters"
HOMEPAGE="http://bcm43xx.berlios.de/"
SRC_URI="mirror://sabayon/net-wireless/bcm43xx-firmware/bcm${PV}_firmware-${BC_REVISION}.tar.bz2"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"

src_install() {
	cd ${WORKDIR}/
	insinto /lib/firmware
	doins *.fw
}
