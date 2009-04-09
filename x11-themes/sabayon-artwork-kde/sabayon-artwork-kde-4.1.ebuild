# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official KDE artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-4.0.97.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="
	x11-themes/sabayon-artwork-core
	x11-themes/gtk-engines
	x11-themes/gtk-engines-murrine
	!<=x11-themes/sabayonlinux-artwork-4
	!x11-themes/sabayon-artwork-star
	!x11-themes/sabayon-artwork-darkblend
	"

S="${WORKDIR}/${PN}"

src_install() {

	## KDE 3.5

	# KDM theme
	cd ${S}/kdm3.5
	mv Sabayon-4.0 Sabayon
	mv Sabayon-4.0-wide Sabayon-wide
	insinto /usr/kde/3.5/share/apps/kdm/themes/
	doins -r ./

        # ksplash
	cd ${S}/ksplash3.5/Lines
	dodir /usr/kde/3.5/share/apps/ksplash/Themes/Lines
	insinto /usr/kde/3.5/share/apps/ksplash/Themes/Lines
	doins -r ./

        # theme
	dodir /usr/share/apps/kthememanager/themes
	insinto /usr/share/apps/kthememanager/themes
	cd ${S}/kde3.5
	mkdir Sabayon4
	tar xf Sabayon4.kth -C Sabayon4
	rm *.kth
	doins -r ./

	## KDE 4
	dodir /usr/kde/4.2/share/apps/kdm/themes
	cd ${S}/kdm4
	insinto /usr/kde/4.2/share/apps/kdm/themes
	doins -r ./

}

pkg_postinst () {
	einfo "This is a prelease - ${PVR}"
	einfo "Please report bugs or glitches to"
	einfo "bugs.sabayonlinux.org"
}
