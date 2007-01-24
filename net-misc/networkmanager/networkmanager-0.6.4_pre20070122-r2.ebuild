# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.6.4_pre20061028.ebuild,v 1.2 2006/11/05 01:36:44 steev Exp $

inherit gnome2 eutils

DESCRIPTION="Network configuration and management in an easy way. Desktop env independent"
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
SRC_URI="http://dev.gentoo.org/~metalgod/files/NetworkManager-0.6.4_pre20061028.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="crypt doc gnome"

RDEPEND=">=sys-apps/dbus-0.60
	>=sys-apps/hal-0.5
	sys-apps/iproute2
	>=dev-libs/libnl-1.0_pre6
	net-misc/dhcdbd
	>=net-wireless/wireless-tools-28_pre9
	>=net-wireless/wpa_supplicant-0.4.8
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

S=${WORKDIR}/NetworkManager

DOCS="AUTHORS COPYING ChangeLog INSTALL NEWS README"
USE_DESTDIR="1"

src_unpack () {
	unpack ${A}
	cd ${S}

        epatch ${FILESDIR}/${PN}-updatedbackend.patch
        epatch ${FILESDIR}/${PN}-use-kernel-headers.patch
        epatch ${FILESDIR}/${PN}-resolvconf-perms.patch
        epatch ${FILESDIR}/${PN}-0.6.4-gentooinitscript.patch
        epatch ${FILESDIR}/${PN}-0.6.4-confchanges.patch

	# Adds support for knm to utilize static IP and "profiles"
	# THIS PATCH BREAKS COMPILATION !!!!!!!!!!!!!!!!
	epatch ${FILESDIR}/nm-dhcp-manager.c.patch
	
	# From the Mailing list, while we're waiting for a version bump
	epatch ${FILESDIR}/${PN}-0.6.4-fix-various-memleaks.patch
	epatch ${FILESDIR}/${PN}-0.6.4-fix-nm-applet-memleaks.patch

	# Dbus 1.0 support
	epatch ${FILESDIR}/${PN}-0.6.4-dbus-1.0.patch

	# Fix possible early-xdm related problem
	epatch ${FILESDIR}/networkmanager-0.6.4-force-before-xdm.patch

	# Fix possible associations problems
	epatch ${FILESDIR}/networkmanager-0.6.4-high-delay.patch

	# Add some workarounds for various drivers
	epatch ${FILESDIR}/networkmanager-0.6.4-wireless-drivers-workarounds.patch
}

src_compile() {

	G2CONF="${G2CONF} \
		`use_with crypt gcrypt` \
		--disable-more-warnings \
		--localstatedir=/var \
		--with-distro=gentoo \
		--with-dbus-sys=/etc/dbus-1/system.d"

	if use gnome; then
		G2CONF="${G2CONF} --enable-notification-icon"
	else
		G2CONF="${G2CONF} --without-gnome"
	fi

	gnome2_src_compile

}

src_install() {
	gnome2_src_install
	keepdir /var/run/NetworkManager
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
