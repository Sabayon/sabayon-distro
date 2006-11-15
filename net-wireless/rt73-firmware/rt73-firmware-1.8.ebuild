# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Firmware for Wireless Ralink RT61 based cards"

HOMEPAGE="http://www.ralinktech.com/supp-1.htm"
SRC_URI="http://www.ralinktech.com/drivers/Linux/RT71W_Firmware_V${PV}.zip"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"

src_install() {
	cd ${WORKDIR}/RT71W_Firmware_V${PV}
	insinto /lib/firmware
	doins *.bin
}
