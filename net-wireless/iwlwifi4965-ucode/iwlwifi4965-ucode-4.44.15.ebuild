# Copyright 2007 Sabayon Linux

DESCRIPTION="New daemonless microcode for the Intel PRO/Wireless 4965 miniPCI express adapter"

HOMEPAGE="http://intellinuxwireless.org/?p=iwlwifi"
SRC_URI="http://intellinuxwireless.org/iwlwifi/downloads/iwlwifi-4965-ucode-${PV}.tgz"
LICENSE="iwlwifi-ucode"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"
S=${WORKDIR}/iwlwifi-4965-ucode-${PV}

src_install() {
	cd ${S}
	insinto /lib/firmware
	doins iwlwifi-4965.ucode LICENSE.*
	dodoc README.*
}
