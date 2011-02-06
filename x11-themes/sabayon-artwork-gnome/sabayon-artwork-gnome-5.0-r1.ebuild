# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official GNOME artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="~x11-themes/sabayon-artwork-core-${PV}
	 x11-themes/gtk-engines
	 x11-themes/gtk-engines-murrine
	!x11-themes/murrine
	!<=x11-themes/sabayonlinux-artwork-4"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd ${S}/gtk/Saburreza/gtk-2.0
	epatch "${FILESDIR}/fix-saburreza-panelrc.patch"
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
	ewarn "If your Firefox Toolbar is incorrect, run /usr/share/themes/fixfirefox.sh"
	ewarn " " 
	einfo "Please report bugs or glitches to"
	einfo "bugs.sabayonlinux.org"
}
