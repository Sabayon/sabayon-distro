# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils gnome2
#inherit autotools eutils gnome2

DESCRIPTION="An RSS reader plugin for Evolution"
HOMEPAGE="http://gnome.eu.org/evo/index.php/Evolution_RSS_Reader_Plugin"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+gtk3 nls webkit"
RDEPEND="app-text/enchant
	dev-libs/dbus-glib
	dev-libs/expat
	>=dev-libs/glib-2.26.1:2
	>=gnome-base/gconf-2.32.0-r1
	>=gnome-base/libglade-2
	gnome-base/orbit:2
	gnome-extra/evolution-data-server
	net-libs/libsoup:2.4
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0
	x11-libs/pango
	webkit? ( net-libs/webkit-gtk )
	gtk3? (
		gnome-extra/gtkhtml:4.0
		net-libs/webkit-gtk:3
		x11-libs/gtk+:3
		>=mail-client/evolution-3
	)
	!gtk3? (
		gnome-extra/gtkhtml:3.14
		net-libs/webkit-gtk:2
		x11-libs/gtk+:2
		<mail-client/evolution-3
	)"

# does not compile with gecko
#xulrunner? ( || (
#		net-libs/xulrunner:1.9
#		www-client/seamonkey
#		www-client/firefox ) )

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.35.0
	gnome-base/gnome-common
	>=sys-devel/autoconf-2.53
	>=sys-devel/automake-1.8
	>=sys-devel/libtool-0.25" # gnome-autogen.sh

DOCS="AUTHORS ChangeLog FAQ NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-schemas-install
		$(use_enable nls)
		$(use_enable webkit)"
}

src_prepare() {
	gnome2_src_prepare

	# https://bugzilla.gnome.org/show_bug.cgi?id=654591
	sed -i -e 's|^\(#define EVOLUTION\) EVOLUTION_BINDIR.*$|\1 "evolution\&"|' \
		src/evolution-import-rss.c || die "sed failed"

	# intltoolize --force --copy --automake || die "intltoolize failed"
	# eautoreconf
	NOCONFIGURE=1 ./autogen.sh || die "autogen failed"
}
