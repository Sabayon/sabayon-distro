# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/linux-wlan-ng-modules/linux-wlan-ng-modules-0.2.8-r1.ebuild,v 1.1 2007/12/29 23:38:19 betelgeuse Exp $

inherit eutils linux-mod

MY_PN=${PN/-modules/}
MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Kernel modules for Prism2/2.5/3 based 802.11b USB wireless LAN products"
HOMEPAGE="http://linux-wlan.org"
SRC_URI="ftp://ftp.linux-wlan.org/pub/linux-wlan-ng/${MY_P}.tar.bz2"

LICENSE="|| ( GPL-2 MPL-1.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="debug"

BUILD_TARGETS="default"
BUILD_PARAMS="WLAN_SRC=${S}/src"

DEPEND="!<net-wireless/linux-wlan-ng-0.2.2"

CONFIG_CHECK="WIRELESS_EXT"

pkg_setup() {
	# We have to put this to the global scope inside the function or it will be
	# reset between functions because the ebuild is sourced many times.

	MODULE_NAMES="p80211(net/wireless:${S}/src/p80211)"
	MODULE_NAMES="${MODULE_NAMES} prism2_usb(net/wireless:${S}/src/prism2/driver)"

	linux-mod_pkg_setup
}

config_by_usevar() {
	local config=${3}
	[[ -z ${config} ]] && config=${S}/default.config

	if use ${2}; then
		echo "${1}=y" >> ${config}
	else
		echo "${1}=n" >> ${config}
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${MY_PN}-0.2.5-sandbox.patch"
	epatch "${FILESDIR}/0.2.8-sk_buff-mac.patch"
	epatch "${FILESDIR}/${P}-2.6.24.patch"

	local config=${S}/default.config
	cp "${S}/config.in" "${config}" || die

	cat > "${config}" <<-EOF
		TARGET_ROOT_ON_HOST="${D}"
		LINUX_SRC="${KERNEL_DIR}"
		FIRMWARE_DIR=/lib/firmware/
		PRISM2_PCI=n
		PRISM2_PLX=n
		PRISM2_PCMCIA=n
		PRISM2_USB=y
	EOF

	config_by_usevar WLAN_DEBUG debug

	sed -i -e "s:dep modules:modules:" "${S}/src/p80211/Makefile"
}

src_compile() {
	set_arch_to_kernel
	emake default_config || die "emake default_config failed"
	set_arch_to_portage

	cd "${S}/src/mkmeta"
	emake || die "emake mkmeta failed"

	linux-mod_src_compile
}

pkg_postinst() {
	linux-mod_pkg_postinst

	einfo "Support for pci, plx and pcmcia drivers has been removed in"
	einfo "revision. For pci, plx and pcmcia drivers try for example"
	einfo "the hostap-driver or orinoco drivers. They both work with the"
	einfo "standard wireless tools."
	einfo ""
	einfo "If they do not work, please report this to betelgeuse@gentoo.org."
}
