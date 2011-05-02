# Copyright 2004-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
#

inherit eutils

DESCRIPTION="Sabayon LXDE Artwork"
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
	cd ${S}/lxdm
	dodir /usr/share/lxdm/themes/Sabayon
	insinto /usr/share/lxdm/themes/Sabayon
	doins Sabayon/*
}
