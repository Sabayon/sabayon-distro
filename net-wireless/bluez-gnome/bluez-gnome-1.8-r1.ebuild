# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez-gnome/bluez-gnome-1.8.ebuild,v 1.7 2009/11/21 15:18:44 armin76 Exp $

EAPI="2"

inherit eutils gnome2

DESCRIPTION="Bluetooth helpers for GNOME"
HOMEPAGE="http://www.bluez.org/"
SRC_URI="mirror://kernel/linux/bluetooth/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~hppa ~ppc x86"

IUSE="gnome"
COMMON_DEPEND="dev-libs/glib:2
	>=x11-libs/libnotify-0.3.2
	>=gnome-base/gconf-2.6
	>=dev-libs/dbus-glib-0.60
	sys-apps/hal
	>=x11-libs/gtk+-2.6"
DEPEND="
	dev-util/pkgconfig
	x11-proto/xproto
	${COMMON_DEPEND}"
RDEPEND="net-wireless/bluez
	gnome? ( gnome-base/nautilus gnome-base/gvfs[bluetooth] )
	>=app-mobilephone/obex-data-server-0.4
	${COMMON_DEPEND}"

G2CONF="--disable-desktop-update
		--disable-mime-update
		--disable-icon-update"

DOCS="AUTHORS README NEWS ChangeLog"

src_prepare() {
	gnome2_src_prepare
	epatch "${FILESDIR}/${PV}-ODS-API.patch"
}

src_install() {
	gnome2_src_install

	# hackish fix to libGL issue, this should be fixed in code, really
	mv "${D}"/usr/bin/bluetooth-applet "${D}"/usr/bin/bluetooth-applet.orig || \
		die "cannot move bluetooth-applet"
	echo "#!/bin/sh
LD_PRELOAD=/usr/lib/opengl/xorg-x11/lib/libGL.so /usr/bin/bluetooth-applet.orig \${@}
" > "${D}"/usr/bin/bluetooth-applet
	chmod 0755 "${D}"/usr/bin/bluetooth-applet
}
