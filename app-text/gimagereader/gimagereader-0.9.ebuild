# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
inherit python distutils

DESCRIPTION="A tesseract OCR front-end"
HOMEPAGE="http://www.sourceforge.com/projects/gimagereader"
SRC_URI="mirror://sourceforge/${PN}/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
	app-text/tesseract
	dev-python/gtkspell-python
	dev-python/imaging
	dev-python/pycairo
	dev-python/pyenchant
	dev-python/pygtk
	dev-python/python-poppler
"
src_prepare() {
	sed "/data.append/s/'COPYING',//" \
		-i setup.py
}
