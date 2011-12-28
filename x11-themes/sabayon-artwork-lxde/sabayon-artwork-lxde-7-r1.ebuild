# Copyright 2004-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
#

EAPI=3

inherit base

REAL_PV="6_beta2"
REAL_P="${PN}-${REAL_PV}"
DESCRIPTION="Sabayon LXDE Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${REAL_P}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~arm ~x86 ~amd64"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${PN}"

PATCHES=(
	"${FILESDIR}/${P}-fix-background-image-ext.patch"
	"${FILESDIR}/${P}-lxdm-theme-colors.patch"
)

src_install () {
	cd "${S}"/lxdm
	dodir /usr/share/lxdm/themes/Sabayon
	insinto /usr/share/lxdm/themes/Sabayon
	doins Sabayon/*
	dosym /usr/share/backgrounds/kgdm.jpg \
		/usr/share/lxdm/themes/Sabayon/kgdm.jpg
}
