# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Provides core UI functions for the GNOME 3 desktop"
HOMEPAGE="http://live.gnome.org/GnomeShell"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/glib-2.20
	>=x11-libs/gtk+-2.16
	>=media-libs/gstreamer-0.10.16
	>=media-libs/gst-plugins-base-0.10.16
	>=gnome-base/gnome-desktop-2.26
	>=dev-libs/gobject-introspection-0.6.5

	dev-libs/dbus-glib
	dev-libs/gjs
	media-libs/clutter:1.0[opengl,introspection]
	dev-libs/libcroco:0.6

	gnome-base/gconf
	gnome-base/gnome-menus
	gnome-base/librsvg

	x11-libs/startup-notification
	x11-libs/libXfixes
	x11-wm/mutter[introspection]
	x11-apps/mesa-progs
"
DEPEND="${RDEPEND}
	>=dev-lang/python-2.5
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.26
	gnome-base/gnome-common
"
DOCS="AUTHORS ChangeLog NEWS README"
