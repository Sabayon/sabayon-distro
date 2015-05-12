# Copyright 1999-2015 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# 

EAPI=4
inherit multilib

DESCRIPTION="Sabayon LibreOffice Artwork"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

DEPEND="sys-apps/sed"
RDEPEND=""

S=${WORKDIR}/${PN}

src_install () {
	cd "${S}/images"
	sed -i "s:650:620:" sofficerc || die
	insinto /usr/$(get_libdir)/libreoffice/program
        doins *.png sofficerc
}

pkg_postinst () {
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayon.org"
}
