# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/rt2500/rt2500-1.1.0_pre2007020911.ebuild,v 1.4 2007/02/13 17:16:19 wolf31o2 Exp $

inherit eutils linux-mod kde-functions
set-qtdir 3

MY_P="${P/_beta/-b}"
DESCRIPTION="Driver for the RaLink RT2500 wireless chipset"
HOMEPAGE="http://rt2x00.serialmonkey.com"
#SRC_URI="mirror://sourceforge/rt2400/${MY_P}.tar.gz"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"
LICENSE="GPL-2"

KEYWORDS="amd64 ~hppa ppc x86"
IUSE="qt3"
DEPEND="net-wireless/wireless-tools
	qt3? ( =x11-libs/qt-3* )"

#S="${WORKDIR}/${MY_P}"
S="${WORKDIR}/rt2500-cvs-2007020911"

MODULE_NAMES="rt2500(net:${S}/Module)"
CONFIG_CHECK="NET_RADIO"
MODULESD_RT2500_ALIASES=('ra? rt2500')

pkg_setup() {
	linux-mod_pkg_setup
	if use_m ; then
		BUILD_PARAMS="-C ${KV_DIR} M=${S}/Module"
		BUILD_TARGETS="modules"
	else
		die "please use a kernel >=2.6.6"
	fi
}

src_compile() {
	linux-mod_src_compile

	if use qt3; then
		cd "${S}"/Utilitys
		"${QTDIR}"/bin/qmake -o Makefile raconfig2500.pro
		emake || die "make Utilities failed"
	fi
}

src_install() {
	linux-mod_src_install

	dodoc Module/README Module/TESTING Module/iwpriv_usage.txt \
		THANKS FAQ CHANGELOG

	if use qt3; then
		dobin ${S}/Utilitys/RaConfig2500
		doicon Utilitys/ico/RaConfig2500.xpm
		make_desktop_entry RaConfig2500 "RaLink RT2500 Config" RaConfig2500.xpm
		insinto /etc/Wireless/RT2500STA
		doins Module/RT2500STA.dat
	fi
}
