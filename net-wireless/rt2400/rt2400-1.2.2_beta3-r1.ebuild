# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/rt2400/rt2400-1.2.2_beta3.ebuild,v 1.3 2006/06/24 01:23:51 cardoe Exp $

inherit eutils linux-mod kde-functions
set-qtdir 3

MY_P="${P/_beta/-b}"
DESCRIPTION="Driver for the RaLink RT2400 wireless chipset"
HOMEPAGE="http://rt2x00.serialmonkey.com"
SRC_URI="http://rt2x00.serialmonkey.com/${MY_P}.tar.gz"
LICENSE="GPL-2"

KEYWORDS="~x86"
IUSE="qt3"
DEPEND="net-wireless/wireless-tools
	qt3? ( =x11-libs/qt-3* )"

S=${WORKDIR}/${MY_P}
MODULE_NAMES="rt2400(net:${S}/Module)"
CONFIG_CHECK="NET_RADIO BROKEN_ON_SMP"
BROKEN_ON_SMP_ERROR="SMP Processors and Kernels are currently not supported"
MODULESD_RT2400_ALIASES=('ra? rt2400')


pkg_setup() {
	linux-mod_pkg_setup
	if use_m
	then BUILD_PARAMS="-C ${KV_DIR} M=${S}/Module"
		 BUILD_TARGETS="modules"
	else die "please use a kernel >=2.6.6"
	fi
}

src_compile() {
	cd ${S}
	epatch ${FILESDIR}/rt2400-1.2.3_beta3-2.6.17.patch
	if use qt3; then
		cd ${S}/Utility
		${QTDIR}/bin/qmake -o Makefile raconfig2400.pro
		emake || die "make Utilities failed"
	fi

	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	if use qt3; then
		dobin ${S}/Utility/RaConfig2400
		doicon Utility/ico/raconfig.xpm
		make_desktop_entry RaConfig2400 "RaLink RT2400 Config" raconfig.xpm
	fi

	dodoc Module/TESTING THANKS FAQ CHANGELOG
}

pkg_postinst() {
	linux-mod_pkg_postinst

	einfo "to set up the card you can use:"
	einfo "- iwconfig from wireless-tools"
	einfo "- RT2400 provided qt API: RaConfig2400"
}
