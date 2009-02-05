# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit eutils linux-mod

DESCRIPTION="Driver for the RaLink RT2860 wireless chipset"
HOMEPAGE="http://www.ralinktech.com/"
LICENSE="GPL-2"

MY_RELDATE="2008_0918"
MY_P="${MY_RELDATE}_RT2860_Linux_STA_v${PV}"

SRC_URI="http://www.ralinktech.com.tw/data/drivers/${MY_P}.tar.bz2"

KEYWORDS="-* ~amd64 ~x86"
IUSE="networkmanager"
SLOT="0"

DEPEND=""
RDEPEND="net-wireless/wireless-tools"

S="${WORKDIR}/${MY_P}"

MODULE_NAMES="rt2860sta(wireless:${S}/os/linux)"
BUILD_PARAMS="-j1 -C \${KERNEL_DIR} M=\"${S}/os/linux\" PLATFORM=PC CHIPSET=2860 \
RT28xx_DIR=\"${S}\" RT28xx_MODE=STA"
BUILD_TARGETS="clean modules"
CONFIG_CHECK="WIRELESS_EXT"
ERROR_WIRELESS_EXT="${P} requires support for Wireless LAN drivers (non-hamradio) & Wireless Extensions (CONFIG_WIRELESS_EXT)."

src_compile() {
	if kernel_is 2 6; then
		cp -f os/linux/Makefile.6 os/linux/Makefile
	elif kernel_is 2 4; then
		cp -f os/linux/Makefile.4 os/linux/Makefile
	else
		die "Your kernel version is not supported!"
	fi

	sed -i -e "s:^HAS_WPA_SUPPLICANT=n:HAS_WPA_SUPPLICANT=y:g" os/linux/config.mk
	use networkmanager && sed -i -e \
		"s:^HAS_NATIVE_WPA_SUPPLICANT_SUPPORT=n:HAS_NATIVE_WPA_SUPPLICANT_SUPPORT=y:g" \
		os/linux/config.mk

	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	dodoc iwpriv_usage.txt README_STA

	insinto /etc/Wireless/RT2860STA
	insopts -m 0600
	doins RT2860STA.dat
}
