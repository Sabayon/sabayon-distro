# Copyright 1999-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils multilib

DESCRIPTION="Store, Sync and Share Files Online"
HOMEPAGE="http://www.getdropbox.com/"
SRC_URI="http://www.getdropbox.com/download?dl=packages/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

RDEPEND=">=gnome-base/nautilus-2.16
	>=x11-libs/gtk+-2.12
	>=net-misc/wget-1.10
	>=dev-libs/glib-2.14
	>=x11-libs/libnotify-0.4.4"
DEPEND="${RDEPEND}"

DOCS="AUTHORS NEWS README"

pkg_setup () {
	G2CONF="${G2CONF} $(use_enable debug)"
}

