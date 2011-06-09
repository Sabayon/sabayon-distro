# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
#

EAPI=4

DESCRIPTION="Sabayon Linux Official GNOME artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_configure() {
	einfo "Nothing to configure"
}

src_compile() {
	einfo "Nothing to compile"
}


src_install() {
	dodir /usr/share/themes
	dodir /usr/share/gdm/themes

	# Gnome & GTK Theme
	cd ${S}/gtk
	dodir /usr/share/themes
	insinto /usr/share/themes
	doins -r ./*

	# Metacity
	cd ${S}/metacity
	insinto /usr/share/themes
	doins -r ./*

	# Panel Image
	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.png

	# GDM theme
	cd ${S}/gdm
	insinto /usr/share/gdm/themes
	doins -r ./*
}

pkg_postinst () {
	gtk-update-icon-cache
	einfo "Please report glitches to bugs.sabayon.org"
}

pkg_postrm () {
	gtk-update-icon-cache
}

