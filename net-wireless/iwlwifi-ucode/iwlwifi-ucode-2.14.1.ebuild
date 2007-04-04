# Copyright 2007 Sabayon Linux

DESCRIPTION="New daemonless microcode for the Intel PRO/Wireless 3945ABG miniPCI express adapter"

HOMEPAGE="http://intellinuxwireless.org/?p=iwlwifi"
SRC_URI="http://intellinuxwireless.org/iwlwifi/downloads/${P}.tgz"

LICENSE="iwlwifi-ucode"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"

src_install() {
	insinto /lib/firmware
	doins iwlwifi-3945.ucode LICENSE.${PN}

	dodoc README.${PN}
}
