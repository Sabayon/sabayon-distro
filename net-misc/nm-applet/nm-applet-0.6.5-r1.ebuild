# Copyright 1999-2006 Gentoo Foundation
# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit gnome2 eutils

DESCRIPTION="NetworkManager GNOME Client Applet"
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
SRC_URI="http://people.redhat.com/dcbw/NetworkManager/${PV}/nm-applet-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""

RDEPEND="
	>=net-misc/networkmanager-${PV}
	>=x11-libs/libnotify-0.4
	>=x11-libs/gtk+-2.8
	>=gnome-base/libglade-2
	>=gnome-base/gnome-keyring-0.4
	>=gnome-base/gnome-panel-2
	>=gnome-base/gconf-2
	>=gnome-base/libgnomeui-2 
	"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"


DOCS="AUTHORS COPYING ChangeLog INSTALL NEWS README"
USE_DESTDIR="1"

src_unpack () {
	unpack ${A}
	cd ${S}

	# add space for dbus conf patch
	epatch ${FILESDIR}/${P}-confchanges.patch
}

src_compile() {

	G2CONF="${G2CONF} \
		--localstatedir=/var \
		--with-notify \
		--with-dbus-sys=/etc/dbus-1/system.d"

	gnome2_src_compile

}

pkg_postinst() {
	gnome2_icon_cache_update
	einfo
	einfo "NetworkManager doesn't work with all wifi devices"
	einfo "to see if your card is supported please visit"
	einfo "http://live.gnome.org/NetworkManagerHardware"
	einfo
	einfo "You can use NetworkManager instead of baselayout"
	einfo "to manage your networks but you are advised to use"
	einfo "baselayout because NetworkManager is beta software"
	einfo "and don't work fully as expected."
	einfo
	einfo "If it's the first time you run NetworkManager please"
	einfo "restart dbus doing /etc/init.d/dbus restart"
	einfo
	einfo "To use NetworkManager disable all entries on runlevels"
	einfo "net.***X and run /etc/init.d/NetworkManager"
	einfo "you can add to runlevels writing on your terminal"
	einfo "rc-update add NetworkManager default"
	einfo
	ebeep
}
