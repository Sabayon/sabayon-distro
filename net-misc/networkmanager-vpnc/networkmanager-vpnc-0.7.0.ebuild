# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 debug eutils

DESCRIPTION="NetworkManager vpnc daemon/client configuration and management in an easy way."
HOMEPAGE="http://people.redhat.com/dcbw/NetworkManager/"
SRC_URI="http://www.steev.net/files/distfiles/NetworkManager-vpnc-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="crypt debug doc gnome"

RDEPEND=">=sys-apps/dbus-0.60
	>=sys-apps/hal-0.5
	sys-apps/iproute2
	>=dev-libs/libnl-1.0_pre6
	>=net-misc/dhcdbd-1.4
	>=net-wireless/wireless-tools-28_pre9
	>=net-wireless/wpa_supplicant-0.4.8
	>=net-misc/networkmanager-0.6.2
	>=net-misc/vpnc-0.3.3
	>=dev-libs/glib-2.8
	>=x11-libs/libnotify-0.3.2
	gnome? ( >=x11-libs/gtk+-2.8
		>=gnome-base/libglade-2
		>=gnome-base/gnome-keyring-0.4
		>=gnome-base/gnome-panel-2
		>=gnome-base/gconf-2
		>=gnome-base/libgnomeui-2 )
	crypt? ( dev-libs/libgcrypt )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

S=${WORKDIR}/NetworkManager-vpnc-${PV}

DOCS="AUTHORS COPYING ChangeLog INSTALL NEWS README"
USE_DESTDIR="1"

G2CONF="${G2CONF} \
	`use_with crypt gcrypt` \
	--disable-more-warnings \
	--with-dbus-sys=/etc/dbus-1/system.d \
	--enable-notification-icon"

src_unpack () {

	unpack ${A}
	cd ${S}
	# Gentoo puts vpnc somewhere that the source doesn't expect.
	epatch ${FILESDIR}/nm-vpnc-path.patch
	# Match the same dbus permissions as NetworkManager
	epatch ${FILESDIR}/nm-vpnc-dbus_conf.patch
}
