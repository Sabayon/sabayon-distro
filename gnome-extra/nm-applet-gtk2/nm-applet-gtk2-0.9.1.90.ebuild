# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/nm-applet/nm-applet-0.9.0.ebuild,v 1.1 2011/08/23 23:18:30 nirbheek Exp $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
GNOME_ORG_MODULE="network-manager-applet"

inherit gnome2

DESCRIPTION="GNOME applet for NetworkManager, gtk+-2 flavour"
HOMEPAGE="http://projects.gnome.org/NetworkManager/"

LICENSE="GPL-2"
SLOT="0"
IUSE="bluetooth"
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="!gnome-extra/nm-applet
	>=dev-libs/glib-2.16:2
	>=dev-libs/dbus-glib-0.88
	>=gnome-base/gconf-2.20:2
	>=gnome-base/gnome-keyring-2.20
	>=sys-apps/dbus-1.4.1
	>=sys-auth/polkit-0.96-r1
	>=x11-libs/gtk+-2.20:2
	>=x11-libs/libnotify-0.7.0

	app-text/iso-codes
	>=net-misc/networkmanager-${PV}
	net-misc/mobile-broadband-provider-info

	bluetooth? ( >=net-wireless/gnome-bluetooth-2.27.6 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.40"

pkg_setup() {
	DOCS="AUTHORS ChangeLog NEWS README"
	G2CONF="${G2CONF}
		--with-gtkver=2
		--disable-more-warnings
		--disable-static
		--localstatedir=/var
		$(use_with bluetooth)"
}
