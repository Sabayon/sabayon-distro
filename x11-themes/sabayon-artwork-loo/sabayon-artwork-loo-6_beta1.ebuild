# Copyright 1999-2011 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# 

EAPI=4
inherit multilib

DESCRIPTION="Sabayon LibreOffice Artwork"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${PN}

src_install () {
	insinto /usr/$(get_libdir)/libreoffice/program
	doins *.png sofficerc
}

pkg_postinst () {
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayon.org"
}
