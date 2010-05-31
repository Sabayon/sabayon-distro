# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2

MY_PN="${PN/-themes}"

DESCRIPTION="Official themes for Cairo-dock"
HOMEPAGE="http://www.cairo-dock.org"
SRC_URI="mirror://berlios/${MY_PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">x11-misc/cairo-dock-2.1.3"
