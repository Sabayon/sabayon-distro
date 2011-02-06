# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official artwork, can include wallpapers, ksplash, and GTK/QT Themes."
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-4.0.97.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="!<=x11-themes/sabayonlinux-artwork-4
	!<x11-themes/sabayon-artwork-4
	!x11-themes/sabayon-artwork-star
	!x11-themes/sabayon-artwork-darkblend
	"

S="${WORKDIR}/${PN}"

src_install () {
	# Gensplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Cursors
	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	# Wallpaper
	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.png
}

pkg_postinst () {
	ewarn "This is a prelease - ${PV}"
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayonlinux.org"
}
