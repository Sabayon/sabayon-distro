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

PATCHES=( "${FILESDIR}/${PN}-7-fix-background-image-ext.patch" )

src_install () {
	cd "${S}"/lxdm
	dodir /usr/share/lxdm/themes/Sabayon
	insinto /usr/share/lxdm/themes/Sabayon
	doins Sabayon/*

	# both provided by sabayon-artwork-core
	for lame_format in png jpg; do
		dosym /usr/share/backgrounds/kgdm.${lame_format} \
			/usr/share/lxdm/themes/Sabayon/kgdm.${lame_format}
	done
}
