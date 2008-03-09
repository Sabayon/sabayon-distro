# Copyright 2008 Daniel Gryniewciz
# Distributed under the terms of the GNU General Public License v2

inherit distutils python

DESCRIPTION="Good plugins for the Elisa "
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/elisa/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE=""

MAKEOPTS="-j1"

RDEPEND=""
DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog COPYING NEWS"

