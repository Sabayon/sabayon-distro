# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="python module for gtk-based applications registering global key
bindings"
HOMEPAGE="http://kaizer.se/wiki/python-keybinder/"
SRC_URI="http://kaizer.se/publicfiles/${PN}/${P}.tar.gz"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.5"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install
}
