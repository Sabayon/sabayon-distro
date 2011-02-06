# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils kde4-base

DESCRIPTION="Sabayon Linux Official KDE artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="~x11-themes/sabayon-artwork-core-${PV}
	!<=x11-themes/sabayonlinux-artwork-4
	x11-themes/qtcurve-qt4
	x11-themes/gtk-engines-qtcurve
	kde-misc/kcm_gtk"

S="${WORKDIR}/${PN}"

src_configure() {
	einfo "nothing to configure"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	# KDM
	dodir ${KDEDIR}/share/apps/kdm/themes
	cd ${S}/kdm
	insinto ${KDEDIR}/share/apps/kdm/themes
	doins -r ./

	# KSplash
	dodir ${KDEDIR}/share/apps/ksplash/Themes
	cd ${S}/ksplash
	insinto ${KDEDIR}/share/apps/ksplash/Themes
	doins -r ./
}
