# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="An RSS reader plugin for Evolution"
HOMEPAGE="http://gnome.eu.org/evo/index.php/Evolution_RSS_Reader_Plugin"
SRC_URI="http://gnome.eu.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="dbus webkit"

RDEPEND=">=mail-client/evolution-2.32
	>=gnome-base/gconf-2.32.0-r1
	net-libs/libsoup:2.4
	>=dev-libs/glib-2.26.1:2
	>=gnome-base/libglade-2
	>=gnome-extra/gtkhtml-3.32.1:3.14
	>=x11-libs/gtk+-2.22.1-r1:2
	>=gnome-extra/evolution-data-server-2.32
	dbus? ( dev-libs/dbus-glib )
	webkit? ( net-libs/webkit-gtk )"

# does not compile with gecko
#xulrunner? ( || (
#		net-libs/xulrunner:1.9
#		www-client/seamonkey
#		www-client/mozilla-firefox ) )

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.35.0"

DOCS="AUTHORS ChangeLog FAQ NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-schemas-install
		$(use_enable dbus)
		$(use_enable webkit)"

		# $(use_enable xulrunner gecko)
}

src_prepare() {
	gnome2_src_prepare

	# Fix dbus configure flag switch
	epatch "${FILESDIR}"/${PV}-configure.patch

	# intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}
