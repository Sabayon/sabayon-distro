# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils gnome2

DESCRIPTION="This library provides functionality to create applications with extra functionalities."
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.18.0
	>=x11-libs/gtk+-2.14.0:2
	gnome-base/gnome-desktop
	gnome-base/librsvg
	gnome-base/gconf
	gnome-base/gnome-menus"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9"
DOCS="ChangeLog NEWS"

src_prepare() {
	epatch "${FILESDIR}"/*.{patch,diff}
	gnome2_src_prepare
}
