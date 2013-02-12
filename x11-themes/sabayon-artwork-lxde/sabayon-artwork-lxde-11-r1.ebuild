# Copyright 2004-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
#

EAPI=3

inherit base

DESCRIPTION="Sabayon LXDE Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""
RDEPEND="x11-themes/sabayon-artwork-core"

S="${WORKDIR}/${PN}"

src_install () {
	cd "${S}"/lxdm
	dodir /usr/share/lxdm/themes/Sabayon
	insinto /usr/share/lxdm/themes/Sabayon
	doins Sabayon/*

	dosym /usr/share/backgrounds/kgdm.png \
		/usr/share/lxdm/themes/Sabayon/kgdm.png
}
