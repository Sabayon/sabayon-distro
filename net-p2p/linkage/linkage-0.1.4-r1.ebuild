# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/linkage/linkage-0.1.4.ebuild,v 1.2 2007/11/01 17:33:24 drac Exp $

SCROLLKEEPER_UPDATE="no"
GCONF_DEBUG="no"

inherit gnome2 eutils

DESCRIPTION="BitTorrent client written in C++ using gtkmm and libtorrent."
HOMEPAGE="http://code.google.com/p/linkage"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="curl gnome upnp xfce"

RDEPEND=">=net-libs/rb_libtorrent-0.12
	>=dev-cpp/gtkmm-2.10
	>=dev-cpp/gconfmm-2.6
	>=dev-cpp/libglademm-2.6
	>=x11-libs/libnotify-0.4.4
	>=dev-libs/dbus-glib-0.73
	curl? ( >=net-misc/curl-7.14 )
	gnome? ( >=dev-cpp/libgnomemm-2.16
		>=dev-cpp/gnome-vfsmm-2.16
		>=dev-cpp/libgnomeuimm-2.16 )
	xfce? ( >=xfce-extra/exo-0.3 )
	upnp? ( >=net-libs/gupnp-0.4 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

GCONF2="${GCONF2} $(use_with curl) $(use_with gnome) \
	$(use_with upnp gupnp) $(use_with xfce exo)"

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_unpack () {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}"/linkage-0.1.4-plugin-constructor.patch
}
