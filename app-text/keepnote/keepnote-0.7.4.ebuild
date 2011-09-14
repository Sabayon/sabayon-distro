# Copyright 2010-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
PYTHON_USE_WITH="sqlite xml"

inherit distutils

DESCRIPTION="A note taking application"
HOMEPAGE="http://keepnote.org/keepnote/"
SRC_URI="http://keepnote.org/keepnote/download/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="spell"

DEPEND=">=dev-python/pygtk-2.12.0
	dev-python/pygobject
	dev-python/pygtksourceview
	spell? ( >=app-text/gtkspell-2.0.11-r1 )"

RDEPEND="${DEPEND}"

DOCS="CHANGES README"
