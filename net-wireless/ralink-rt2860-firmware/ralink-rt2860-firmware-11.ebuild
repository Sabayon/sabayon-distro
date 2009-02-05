# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Firmware for Wireless Ralink RT2860PCI/mPCI/PCIe/CB(RT2760/RT2790/RT2860/RT2890"

HOMEPAGE="http://www.ralinktech.com/ralink/Home/Support/Linux.html"
FW_FILE="RT2860_Firmware_V${PV}.zip"
SRC_URI="http://www.ralinktech.com.tw/data/drivers/${FW_FILE}"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"

src_unpack() {
	mkdir ${S} -p
	cd ${WORKDIR}
	cp "${DISTDIR}/${FW_FILE}" .
	unzip ${FW_FILE}
}

src_install() {
	cd ${WORKDIR}/RT2860_Firmware_V${PV}
	insinto /lib/firmware
	doins *.bin
	doins *.txt
}
