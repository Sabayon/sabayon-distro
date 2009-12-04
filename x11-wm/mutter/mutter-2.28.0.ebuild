# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnome2

DESCRIPTION="Upcoming GNOME 3 window manager (derived from metacity)"
HOMEPAGE="http://blogs.gnome.org/metacity/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug introspection test xinerama"

RDEPEND=">=x11-libs/gtk+-2.10
	>=x11-libs/pango-1.2[X]
	>=gnome-base/gconf-2
	>=dev-libs/glib-2.6
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2

	media-libs/clutter:1.0
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXrender

	introspection? ( dev-libs/gobject-introspection )
	xinerama? ( x11-libs/libXinerama )
	gnome-extra/zenity
	!x11-misc/expocity"
DEPEND="${RDEPEND}
	>=app-text/gnome-doc-utils-0.8
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	test? ( app-text/docbook-xml-dtd:4.5 )
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xextproto
	x11-proto/xproto"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README *.txt doc/*.txt"

pkg_setup() {
	G2CONF="${G2CONF}
		--enable-gconf
		--enable-shape
		--enable-sm
		--enable-startup-notification
		--enable-xsync
		--enable-verbose-mode
		$(use_with introspection)
		$(use_enable xinerama)"
}
