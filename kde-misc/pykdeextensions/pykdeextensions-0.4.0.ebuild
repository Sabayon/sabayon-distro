# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="PyKDE Extensions for KDE KControl modules and Guidance"
HOMEPAGE="http://www.riverbankcomputing.co.uk/pykde/"
SRC_URI="http://www.simonzone.com/software/pykdeextensions/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
KEYWORDS="~x86 ~ppc"
IUSE="debug"

RDEPEND="
	>=kde-base/pykde-3.5.0"

src_unpack() {
	unpack ${A}
	# for now... looking for patches?
}

#src_compile() {
#	python setup.py build_libpythonize
#}

src_install() {
	python setup.py install --root=${D}
}
