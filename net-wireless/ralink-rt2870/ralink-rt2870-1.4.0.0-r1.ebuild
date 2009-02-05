# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit eutils linux-mod

DESCRIPTION="Driver for the RaLink RT2870 USB wireless chipsets"
HOMEPAGE="http://www.ralinktech.com/ralink/Home/Support/Linux.html"
LICENSE="GPL-2"

RESTRICT="mirror"

MY_P="2008_0925_RT2870_Linux_STA_v${PV}"

SRC_URI="http://www.ralinktech.com.tw/data/drivers/${MY_P}.tar.bz2"

KEYWORDS="-* ~amd64 x86"
IUSE="debug"
SLOT="0"

DEPEND=""
RDEPEND="net-wireless/wireless-tools"

S="${WORKDIR}/${MY_P}"
MODULE_NAMES="rt2870sta(net:${S}/os/linux)"
#BUILD_TARGETS=" "
MODULESD_RT2870_ALIASES=('ra? rt2870')

CONFIG_CHECK="WIRELESS_EXT"
ERROR_WIRELESS_EXT="${P} requires support for Wireless LAN drivers (non-hamradio) & Wireless Extensions (CONFIG_WIRELESS_EXT)."

src_compile() {
	cd "${S}"
	epatch ${FILESDIR}/${P}-fixes.patch
	epatch ${FILESDIR}/${P}-wpa.patch
	use debug || epatch ${FILESDIR}/${P}-nodebug.patch
	epatch ${FILESDIR}/${P}-cve-2009-0282.patch
	if kernel_is 2 6; then
		cp os/linux/Makefile.6 os/linux/Makefile
	elif kernel_is 2 4; then
		cp os/linux/Makefile.4 os/linux/Makefile
	else
		die "Your kernel version is not supported!"
	fi

	emake || die "Compilation failed!"
#	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	dodoc README_STA iwpriv_usage.txt
	insinto /etc/Wireless/RT2870STA
	insopts -m 0600
	doins RT2870STA.dat
	insopts -m 0644
	doins common/rt2870.bin
}

pkg_postinst() {
	linux-mod_pkg_postinst

	einfo
	einfo "Thanks to RaLink for releasing open drivers!"
	einfo
}

