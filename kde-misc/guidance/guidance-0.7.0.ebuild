# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="System tools for KDE"
HOMEPAGE="http://www.riverbankcomputing.co.uk/guidance/"
SRC_URI="http://www.simonzone.com/software/guidance/${P}.tar.bz2"

RESTRICT="nomirror"

LICENSE="GPL-2"
KEYWORDS="-*"
IUSE="debug"

RDEPEND="
	>=kde-misc/pykdeextensions-0.4.0"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-fix-setup.py.patch
}

src_compile() {
	KDEDIR="`kde-config --prefix`" python setup.py build
}

src_install() {

	KDEDIR="${D}/`kde-config --prefix`" python setup.py install
	#--root=${D}
}
