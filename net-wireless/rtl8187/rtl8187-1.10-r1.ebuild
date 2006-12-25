# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/rtl8187/rtl8187-1.10.ebuild,v 1.3 2006/08/08 08:41:31 genstef Exp $

inherit linux-mod eutils

DESCRIPTION="Driver for the rtl8187 wireless chipset"
HOMEPAGE="http://www.realtek.com.tw"
SRC_URI="http://dev.gentoo.org/~genstef/files/${P}.zip"
#ftp://152.104.238.194/cn/wlan/rtl8187l/linux26x-8187(110).zip
#ftp://61.56.86.122/cn/wlan/rtl8187l/linux26x-8187(110).zip
#ftp://210.51.181.211/cn/wlan/rtl8187l/linux26x-8187(110).zip
#ftp://202.65.194.18/cn/wlan/rtl8187l/linux26x-8187(110).zip

RESTRICT="mirror"
LICENSE="GPL-2"
KEYWORDS="x86"
IUSE=""
DEPEND="app-arch/unzip"
S=${WORKDIR}/${PN}_linuxdrv_V${PV/0}

MODULE_NAMES="ieee80211_crypt-rtl(net:${S}/ieee80211) ieee80211_crypt_wep-rtl(net:${S}/ieee80211)
	ieee80211_crypt_tkip-rtl(net:${S}/ieee80211) ieee80211_crypt_ccmp-rtl(net:${S}/ieee80211)
	ieee80211-rtl(net:${S}/ieee80211) r8187(net:${S}/beta-8187)"
#CONFIG_CHECK="NET_RADIO CRYPTO CRYPTO_ARC4 CRC32 !IEEE80211"
ERROR_IEEE80211="${P} requires the in-kernel version of the IEEE802.11 subsystem to be disabled (CONFIG_IEEE80211)"
BUILD_TARGETS=" "
MODULESD_R8187_ALIASES=("wlan0 r8187")

pkg_setup() {
	if ! kernel_is 2 6 ; then
		eerror "This driver is for kernel version 2.6 or greater only!"
		die "No kernel version 2.6 or greater detected!"
	fi

	linux-mod_pkg_setup
	BUILD_PARAMS="KSRC=${KV_DIR}"
}

src_unpack() {
	unpack ${A} || die "Could not extract ZIP file."
	cd ${S}
	tar xzf stack.tar.gz || die "Could not extract IEEE80211 stack."
	tar xzf drv.tar.gz || die "Could not extract driver."

	sed -i -e 's:MODVERDIR=$(PWD) ::' {beta-8187,ieee80211}/Makefile
	epatch ${FILESDIR}/module-param-and-isoc.patch

	# 2.6.19 support
	epatch ${FILESDIR}/${PN}-2.6.19.patch
}

src_install() {
	linux-mod_src_install

	dodoc ${WORKDIR}/r8187_release_note.txt ReadMe.txt wpa1.conf \
		beta-8187/AUTHORS beta-8187/CHANGES beta-8187/README
}

pkg_postinst() {
	linux-mod_pkg_postinst
	einfo "You may want to add the following modules to /etc/modules.autoload.d/kernel-2.6"
	echo
	einfo "For WEP and WPA encryption"
	echo ieee80211_crypt-rtl
	einfo "WEP encryption"
	echo ieee80211_crypt_wep-rtl
	einfo "WPA TKIP encryption"
	echo ieee80211_crypt_tkip-rtl
	einfo "WPA CCMP encryption"
	echo ieee80211_crypt_ccmp-rtl
	einfo "For the r8187 module"
	echo ieee80211-rtl
	einfo "The module itself"
	echo r8187
}
