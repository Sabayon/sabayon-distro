# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/madwifi-ng/madwifi-ng-0.9.3-r2.ebuild,v 1.2 2007/03/21 15:33:57 steev Exp $

inherit linux-mod

DESCRIPTION="Next Generation driver for Atheros based IEEE 802.11a/b/g wireless LAN cards"
HOMEPAGE="http://www.madwifi.org/"
SRC_URI="http://www.sabayonlinux.org/distfiles/net-wireless/madwifi-ng/madwifi-ng-${PV}.tar.bz2"

LICENSE="atheros-hal
	|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="app-arch/sharutils"
RDEPEND="!net-wireless/madwifi-old
		>=net-wireless/madwifi-ng-tools-0.9.3"

CONFIG_CHECK="CRYPTO WLAN_80211 SYSCTL"
ERROR_CRYPTO="${P} requires Cryptographic API support (CONFIG_CRYPTO)."
ERROR_NET_RADIO="${P} requires support for Wireless LAN drivers (non-hamradio) & Wireless Extensions (CONFIG_WLAN_80211)."
ERROR_SYSCTL="${P} requires Sysctl support (CONFIG_SYSCTL)."
BUILD_TARGETS="all"
MODULESD_ATH_PCI_DOCS="README"

addwrite /usr/src

pkg_setup() {
	linux-mod_pkg_setup

	MODULE_NAMES="ath_hal(net:${S}/ath_hal)
				wlan(net:${S}/net80211)
				wlan_acl(net:${S}/net80211)
				wlan_ccmp(net:${S}/net80211)
				wlan_tkip(net:${S}/net80211)
				wlan_wep(net:${S}/net80211)
				wlan_xauth(net:${S}/net80211)
				wlan_scan_sta(net:${S}/net80211)
				wlan_scan_ap(net:${S}/net80211)
				ath_rate_amrr(net:${S}/ath_rate/amrr)
				ath_rate_onoe(net:${S}/ath_rate/onoe)
				ath_rate_sample(net:${S}/ath_rate/sample)
				ath_pci(net:${S}/ath)"

	BUILD_PARAMS="KERNELPATH=${KV_OUT_DIR}"
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/madwifi-13102007-trunk.patch
	for dir in ath ath_hal net80211 ath_rate ath_rate/amrr ath_rate/onoe ath_rate/sample; do
		convert_to_m ${S}/${dir}/Makefile
	done
	cd ${S}
	touch svnversion.h
}

src_compile() {
	cd ${S}
	ARCHS=${ARCH}
	#unset ARCH
	#make modules || die
	#ARCH=${ARCHS}
	./scripts/if_ath_hal_generator.pl
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	dodoc README THANKS docs/users-guide.pdf docs/WEP-HOWTO.txt

	# install headers for use by
	# net-wireless/wpa_supplicant and net-wireless/hostapd
	insinto /usr/include/madwifi/include/
	doins include/*.h
	insinto /usr/include/madwifi/net80211
	doins net80211/*.h
}

pkg_postinst() {
	local moddir="${ROOT}/lib/modules/${KV_FULL}/net/"

	linux-mod_pkg_postinst

	einfo
	einfo "Interfaces (athX) are now automatically created upon loading the ath_pci"
	einfo "module."
	einfo
	einfo "The type of the created interface can be controlled through the 'autocreate'"
	einfo "module parameter."
	einfo
	einfo "As of net-wireless/madwifi-ng-0.9.3 rate control module selection is done at"
	einfo "module load time via the 'ratectl' module parameter. USE flags amrr and onoe"
	einfo "no longer serve any purpose."
	einfo
	einfo "If you use net-wireless/wpa_supplicant or net-wireless/hostapd with madwifi"
	einfo "you should remerge them now."
	einfo
}
