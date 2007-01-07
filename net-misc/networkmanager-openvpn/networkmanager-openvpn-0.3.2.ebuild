# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils

DESCRIPTION="NetworkManager vpnc daemon/client configuration and management in an easy way."
HOMEPAGE="http://people.redhat.com/dcbw/NetworkManager/"
SRC_URI="http://dev.gentoo.org/~steev/distfiles/NetworkManager-openvpn-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="crypt doc gnome"

RDEPEND=">=sys-apps/dbus-0.35.2
	>=sys-apps/hal-0.5
	sys-apps/iproute2
	>=net-misc/dhcdbd-1.4
	>=net-wireless/wireless-tools-28_pre9
	>=dev-libs/glib-2.8
	>=net-misc/networkmanager-0.5.1
	gnome? ( >=x11-libs/gtk+-2.8
		>=gnome-base/libglade-2
		>=gnome-base/gnome-keyring-0.4
		>=gnome-base/gnome-panel-2
		>=gnome-base/gconf-2
		>=gnome-base/libgnomeui-2 )
	!gnome? ( >=gnome-base/libglade-2
		>=gnome-base/gnome-keyring-0.4
		>=gnome-base/gconf-2 )
	>=net-misc/openvpn-2.0.5
	crypt? ( dev-libs/libgcrypt )"
	
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

S=${WORKDIR}/NetworkManager-openvpn-${PV}

DOCS="AUTHORS COPYING ChangeLog INSTALL NEWS README"
USE_DESTDIR="1"

G2CONF="${G2CONF} \
	`use_with crypt gcrypt` \
	--disable-more-warnings \
	--with-dbus-sys=/etc/dbus-1/system.d \
	--enable-notification-icon"
