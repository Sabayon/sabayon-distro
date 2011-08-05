# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gnome-themes-standard/gnome-themes-standard-3.0.2.ebuild,v 1.2 2011/07/07 13:50:51 pacho Exp $

EAPI="3"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2

DESCRIPTION="Adwaita theme for GNOME Shell"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE=""
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"

# Sabayon, provide our background
SABAYON_RDEPEND="x11-themes/sabayon-artwork-core"
COMMON_DEPEND=">=x11-libs/gtk+-3.0.8:3
	>=x11-themes/gtk-engines-2.15.3:2"
DEPEND="${COMMON_DEPEND}
	>=x11-misc/icon-naming-utils-0.8.7
	>=dev-util/pkgconfig-0.19
	>=dev-util/intltool-0.40
	sys-devel/gettext"
# gnome-themes{,-extras} are OBSOLETE for GNOME 3
# http://comments.gmane.org/gmane.comp.gnome.desktop/44130
RDEPEND="${COMMON_DEPEND} ${SABAYON_RDEPEND}
	!<x11-themes/gnome-themes-2.32.1-r1"

# This ebuild does not install any binaries
RESTRICT="binchecks strip"
# FIXME: --enable-placeholders fails
G2CONF="--disable-static --disable-placeholders"
DOCS="ChangeLog NEWS"

src_prepare() {
	epatch "${FILESDIR}/${PN}-sabayon-default-background.patch"

	gnome2_src_prepare
	# Install cursors in the right place
	sed -e 's:^\(cursordir.*\)icons\(.*\):\1cursors/xorg-x11\2:' \
		-i themes/Adwaita/cursors/Makefile.am \
		-i themes/Adwaita/cursors/Makefile.in || die
}

src_install() {
	gnome2_src_install

	# Make it the default cursor theme
	cd "${ED}/usr/share/cursors/xorg-x11" || die
	ln -sfn Adwaita default || die
}
