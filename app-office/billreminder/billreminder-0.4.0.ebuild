# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit gnome2 gnome2-utils

DESCRIPTION="A desktop bill reminder for GNOME"
HOMEPAGE="http://billreminder.gnulinuxbrasil.org/"
SRC_URI="http://ftp.gnome.org/pub/GNOME/sources/billreminder/0.4/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

DEPEND="|| (
			>=dev-lang/python-2.5
			>=dev-python/pysqlite-2.3
		)
	>=dev-python/dbus-python-0.80
	>=dev-python/pygtk-2.10
"
RDEPEND="${DEPEND}
	dev-python/sqlalchemy
"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable nls)
		--disable-schemas-install"
}

src_prepare() {
	# fix access violations
	epatch "${FILESDIR}"/${P}-makefile-disable-gconf-uninstall.patch
}
