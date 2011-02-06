# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official GNOME artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-4.1.95.tar.lzma"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="x11-themes/sabayon-artwork-core
	 x11-themes/gtk-engines
	 x11-themes/gtk-engines-murrine
	!x11-themes/murrine
	!<=x11-themes/sabayonlinux-artwork-4
	!x11-themes/sabayon-artwork-star
	!x11-themes/sabayon-artwork-darkblend"

S="${WORKDIR}/${PN}"

src_install() {

	dodir /usr/share/themes
	dodir /usr/share/gdm/themes
	
	# Gnome & GTK Theme
	cd ${S}/gtk
	dodir /usr/share/theme
	insinto /usr/share/themes
	doins -r ./*

	# Metacity
	cd ${S}/metacity
	insinto /usr/share/themes
	doins -r ./*

	# GNOME splash
	cd ${S}/gnome-splash
	dodir /usr/share/pixmaps/splash
	insinto /usr/share/pixmaps/splash
	doins *.png

	# Icons
	cd ${S}/icons
	dodir /usr/share/icons
	#insinto /usr/share/icons
	#doins -r ./*
	# We have to use cp to stop portage fscking the symlinks
	cp -Pr gnome-brave ${D}/usr/share/icons/

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
	ewarn "Please run gtk-update-icon-cache and then restart"
	ewarn "any gtk apps to see the icon theme changes"
	ewarn " " 
	einfo "This is a prelease - ${PVR}"
	einfo "Please report bugs or glitches to"
	einfo "bugs.sabayonlinux.org"
}
