# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/ipw3945/ipw3945-1.1.2.ebuild,v 1.1 2006/11/04 14:45:08 phreak Exp $

inherit linux-mod

S=${WORKDIR}/${P/_pre/-pre}

IEEE80211_VERSION="1.1.13-r1"
UCODE_VERSION="1.13"
DAEMON_VERSION="1.7.22"

DESCRIPTION="Driver for the Intel PRO/Wireless 3945ABG miniPCI express adapter"
HOMEPAGE="http://ipw3945.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P/_pre/-pre}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="debug"
DEPEND=">=net-wireless/ieee80211-${IEEE80211_VERSION}"
RDEPEND=">=net-wireless/ieee80211-${IEEE80211_VERSION}
		>=net-wireless/ipw3945-ucode-${UCODE_VERSION}
		>=net-wireless/ipw3945d-${DAEMON_VERSION}"

BUILD_TARGETS="all"
MODULE_NAMES="ipw3945(net/wireless:)"
MODULESD_IPW3945_DOCS="README.ipw3945"

CONFIG_CHECK="NET_RADIO FW_LOADER !IPW3945"
ERROR_NET_RADIO="${P} requires support for Wireless LAN drivers (non-hamradio) & Wireless Extensions (CONFIG_NET_RADIO)."
ERROR_FW_LOADER="${P} requires Hotplug firmware loading support (CONFIG_FW_LOADER)."
ERROR_IPW3945="${P} requires the in-kernel version of the IPW3945 driver to be disabled (CONFIG_IPW3945)"

pkg_setup() {
	linux-mod_pkg_setup

	if kernel_is 2 4; then
		die "${P} does not support building against kernel 2.4.x"
	fi

	if [[ ! -f ${ROOT}/lib/modules/${KV_FULL}/net/ieee80211/ieee80211.${KV_OBJ} ]]; then
		eerror
		eerror "Looks like you forgot to remerge net-wireless/ieee80211 after"
		eerror "upgrading your kernel."
		eerror
		eerror "Hint: use sys-kernel/module-rebuild for keeping track of which"
		eerror "modules needs to be remerged after a kernel upgrade."
		eerror
		die "${ROOT}/lib/modules/${KV_FULL}/net/ieee80211/ieee80211.${KV_OBJ} not found"
	fi

	BUILD_PARAMS="KSRC=${KV_DIR} KSRC_OUTPUT=${KV_OUT_DIR} IEEE80211_INC=/usr/include"
}

src_unpack() {
	local debug="n"

	unpack ${A}

	sed -i \
		-e "s:^#\(CONFIG_IPW3945_QOS\)=.*:\1=y:" \
		-e "s:^# \(CONFIG_IPW3945_MONITOR\)=.*:\1=y:" \
		-e "s:^# \(CONFIG_IEEE80211_RADIOTAP\)=.*:\1=y:" \
		-e "s:^# \(CONFIG_IPW3945_PROMISCUOUS\)=.*:\1=y:" \
		"${S}"/Makefile || die

	use debug && debug="y"
	sed -i -e "s:^\(CONFIG_IPW3945_DEBUG\)=.*:\1=${debug}:" "${S}"/Makefile || die
}

src_compile() {
	linux-mod_src_compile

	einfo
	einfo "You may safely ignore any warnings from above compilation about"
	einfo "undefined references to the ieee80211 subsystem."
	einfo
}

src_install() {
	linux-mod_src_install

	dodoc CHANGES ISSUES
}
