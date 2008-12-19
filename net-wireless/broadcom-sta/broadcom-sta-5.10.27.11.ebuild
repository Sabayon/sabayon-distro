# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit linux-mod

DESCRIPTION="Broadcom's IEEE 802.11a/b/g/n hybrid Linux device driver."
HOMEPAGE="http://www.broadcom.com/support/802.11/linux_sta.php"
SRC_URI="http://www.broadcom.com/docs/linux_sta/hybrid-portsrc-x86-64_5_10_27_11.tar.gz"

LICENSE="broadcom"
KEYWORDS="~x86 ~amd64"
IUSE=""

CONFIG_CHECK="IEEE80211"

S="${WORKDIR}"

MODULE_NAMES="wl(net/wireless)"
MODULESD_WL_ALIASES=("wlan0 wl")


src_unpack() {
	unpack ${A}
	cd ${S}
	if kernel_is ge 2 6 27; then
		epatch "${FILESDIR}/broadcom-build-fix.patch"
	fi
}

src_compile() {
	BUILD_PARAMS="-C ${KV_OUT_DIR} M=${S}"
	BUILD_TARGETS="wl.ko"
	linux-mod_src_compile
}
