# Copyright 2004-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
#

EAPI=3

DESCRIPTION="Sabayon LXDE Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_prepare () {
	sed -i 's#/usr/share/backgrounds/##' \
			"${S}/lxdm/Sabayon/gtkrc" || die "Couldnt fix gtkrc"
}

src_install () {
	cd "${S}"/lxdm
	dodir /usr/share/lxdm/themes/Sabayon
	insinto /usr/share/lxdm/themes/Sabayon
	doins Sabayon/*
	dosym /usr/share/backgrounds/kgdm.jpg \
		/usr/share/lxdm/themes/Sabayon/kgdm.jpg
}
