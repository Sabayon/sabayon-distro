# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2
#

EAPI=3

DESCRIPTION="Official Sabayon Linux Artwork Extras"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {
	# Compiz cube theme
	cd "${S}"/compiz
	dodir /usr/share/compiz
	insinto /usr/share/compiz/
	doins *.png

	# Emerald theme
	cd "${S}"/emerald
	dodir /usr/share/emerald/themes
	insinto /usr/share/emerald/themes/
	doins -r ./
}
