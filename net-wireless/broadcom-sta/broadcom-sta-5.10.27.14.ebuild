# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit linux-mod

DESCRIPTION="Broadcom's IEEE 802.11a/b/g/n hybrid Linux device driver."
HOMEPAGE="http://www.broadcom.com/support/802.11/linux_sta.php"
PKGNAME_AMD64="hybrid-portsrc-x86_64-v5_10_27_14.tar.gz"
PKGNAME_X86="hybrid-portsrc-x86_32-v5_10_27_14.tar.gz"
SRC_URI="http://www.broadcom.com/docs/linux_sta/${PKGNAME_AMD64} http://www.broadcom.com/docs/linux_sta/${PKGNAME_X86}"

LICENSE="broadcom"
KEYWORDS="~x86 ~amd64"
IUSE=""

CONFIG_CHECK="IEEE80211"

S="${WORKDIR}"

MODULE_NAMES="wl(net/wireless)"
MODULESD_WL_ALIASES=("wlan0 wl")


src_unpack() {
	if use amd64; then
		echo ${A}
		unpack "${PKGNAME_AMD64}"
	else
		unpack "${PKGNAME_X86}"
	fi

	cd ${S}
	epatch "${FILESDIR}/${P}-hidden-essid.patch"
}

src_compile() {
	BUILD_PARAMS="-C ${KV_OUT_DIR} M=${S}"
	BUILD_TARGETS="wl.ko"
	linux-mod_src_compile
}
