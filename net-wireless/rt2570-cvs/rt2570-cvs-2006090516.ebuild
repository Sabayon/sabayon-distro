# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils linux-mod

MY_P="${P/-b}"
DESCRIPTION="Driver for the RaLink RT2570 USB wireless chipset"
HOMEPAGE="http://rt2x00.serialmonkey.com"
SRC_URI="http://sabayonlinuxdev.com/distfiles/net-wireless/rt2570-cvs/rt2570-cvs-20060905.tar.gz"
LICENSE="GPL-2"

KEYWORDS="~x86 ~amd64 amd64"
IUSE=""
DEPEND="net-wireless/wireless-tools"

S="${WORKDIR}/${MY_P}"
MODULE_NAMES="rt2570(net:${S}/Module)"


pkg_setup() {
	linux-mod_pkg_setup
	if use_m
	then BUILD_PARAMS="-C ${KV_DIR} M=${S}/Module"
		 BUILD_TARGETS="modules"
	else die "please use a kernel >=2.6.6"
	fi
}

src_compile() {
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	dodoc Module/TESTING Module/iwpriv_usage.txt THANKS FAQ CHANGELOG README
}

pkg_postinst() {
	linux-mod_pkg_postinst

	einfo "to set up the card you can use:"
	einfo "- iwconfig from wireless-tools"
	einfo "- iwpriv, like described in \"/usr/share/doc/${PF}/iwpriv_usage.txt.gz"\"
}

