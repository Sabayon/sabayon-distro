# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils kde4-base 

DESCRIPTION="Sabayon Linux Official KDE artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.lzma"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="
	x11-themes/sabayon-artwork-core
	!<=x11-themes/sabayonlinux-artwork-4
	!x11-themes/sabayon-artwork-star
	!x11-themes/sabayon-artwork-darkblend
	"
PDEPEND="x11-themes/qtcurve-qt4[kde]
	x11-themes/gtk-engines-qtcurve
	x11-themes/gtk-engines-qt"

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
	rm ${D}/usr/kde/4.2/share/apps/ksplash/Themes/Sabayon/Theme.rc~ -f
}
