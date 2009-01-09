# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils python

DESCRIPTION="Good plugins for the Elisa "
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/elisa/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE=""

#MAKEOPTS="-j1"

RDEPEND="=media-tv/elisa-${PV}"


DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog COPYING NEWS"

src_install() {
	distutils_src_install

	# __init__.py is provided by elisa
	rm ${D}/usr/$(get_libdir)/python${PYVER}/site-packages/elisa/plugins/__init__.py
}
