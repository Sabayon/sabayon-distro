# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-vfs-obexftp/gnome-vfs-obexftp-0.4.ebuild,v 1.12 2009/03/22 11:52:48 eva Exp $

GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="OBEX FTP Client for GNOME-VFS"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 hppa ~ppc sparc x86"
IUSE=""

RDEPEND=">=gnome-base/gnome-vfs-2.12.0.1
	dev-libs/dbus-glib
	>=dev-libs/openobex-1.2
	net-wireless/bluez
	net-wireless/bluez-gnome"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS README* docs/*.txt"

pkg_setup() {
	G2CONF="${G2CONF}
		--with-compile-warnings=yes
		--enable-nautilus-workaround"
}
