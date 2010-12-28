# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
EAPI=2
inherit eutils versionator

DESCRIPTION="Sabayon Linux Official GNOME artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
# Need to make sure its not going cause a collision
DEPEDND="!!x11-themes/gnome-colors-themes"
RDEPEND="~x11-themes/sabayon-artwork-core-${PV}
	 x11-themes/gtk-engines"
#PDEPEND to make sure there are no collisions we need to upgrade to 5.3 first
# (to remove the icons). This can be made a RDEP after 5.3.
PDEPEND="x11-themes/gnome-colors-themes"

S="${WORKDIR}/${PN}"

src_prepare() {
        epatch "${FILESDIR}/5.4-gtkrc-hotfix.patch"
}

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

