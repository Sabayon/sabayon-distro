# Copyright 2004-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
#
EAPI=2

inherit eutils

DESCRIPTION="Sabayon Extra Artwork, Including Compiz/Emerald Themes and misc others"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.xz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {
	# Compiz cube theme
	cd ${S}/compiz
	dodir /usr/share/compiz
	insinto /usr/share/compiz/
	doins *.jpg

	# Emerald theme
	cd ${S}/emerald
	dodir /usr/share/emerald/themes
	insinto /usr/share/emerald/themes/
	doins -r ./
}
