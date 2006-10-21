# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils linux-info linux-mod

SPKG="btsco"

DESCRIPTION="BlueTooth headset driver for ALSA (snd-bt-sco)"
HOMEPAGE="http://bluetooth-alsa.sourceforge.net/"
SRC_URI="mirror://sourceforge/bluetooth-alsa/${SPKG}-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

S="${WORKDIR}/${SPKG}-${PV}/kernel"

MODULE_NAMES="snd-bt-sco()"
BUILD_PARAMS="-j1"
BUILD_TARGETS="default"

pkg_setup() {

	if kernel_is 2 4; then
		die "${P} does not support building against kernel 2.4.x"
	fi

	# The wording below is checked for linux-2.6.14.4
	CONFIG_CHECK="BT_SCO BT_HCIUSB_SCO SND_HWDEP"
	ERROR_BT_SCO="BT_SCO is not set! \n\
		Please select 'L2CAP protocol support' and 'SCO links support' under \n\
		Networking|Bluetooth subsystem support|SCO links support"
	ERROR_BT_HCIUSB_SCO="BT_HCIUSB_SCO is not set! \n\
		Please select 'HCI USB driver' under \n\
		Networking|Bluetooth subsystem support|Bluetooth device drivers|SCO (voice) support"
	ERROR_SND_HWDEP="SND_HWDEP is not set! \n\
		Please select a config like SND_USB_AUDIO or SND_EMU10K1; \n\
		look under Device drivers|Sound|ALSA|PCI"

	linux-mod_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd ${S}
	einfo "Patching ${S}/Makefile to use '${KV_DIR}'"
	sed -i ${S}/Makefile -e "s,/lib/modules/\`uname -r\`/build,${KV_DIR},g" || die "Unable to patch Makefile"
}
