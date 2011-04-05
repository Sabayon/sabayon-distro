# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
EAPI="2"
inherit eutils multilib

DESCRIPTION="Sabayon LibreOffice Artwork"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="nomirror"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {
	cd "${S}"
	insinto /usr/$(get_libdir)/libreoffice/program
	doins *.png *.bmp sofficerc
}

pkg_postinst () {
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayon.org"
}
