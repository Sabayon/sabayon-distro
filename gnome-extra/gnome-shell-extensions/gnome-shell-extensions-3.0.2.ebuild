# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="no"
GNOME_TARBALL_SUFFIX="bz2"
GNOME2_LA_PUNT="yes"

inherit gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="JavaScript Extensions for GNOME Shell"
HOMEPAGE="http://live.gnome.org/GnomeShell/Extensions"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

COMMON_DEPEND="
	>=dev-libs/glib-2.26
	>=gnome-base/gnome-desktop-2.91.6:3"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gnome-desktop:3[introspection]
	media-libs/clutter:1.0[introspection]
	net-libs/telepathy-glib[introspection]
	x11-libs/gtk+:3[introspection]
	x11-libs/pango[introspection]"
DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.22
	>=dev-util/intltool-0.26
	gnome-base/gnome-common"

pkg_setup() {
	DOCS="NEWS README"
	G2CONF="${G2CONF}
		--enable-extensions=all
		--disable-schemas-compile"
}

src_install() {
	gnome2_src_install

	# Sabayon: remove broken extension
	rm -r "${ED}/usr/share/gnome-shell/extensions/xrandr-indicator@gnome-shell-extensions.gnome.org" || die
}
