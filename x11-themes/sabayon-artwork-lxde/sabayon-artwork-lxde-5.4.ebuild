# Copyright 2004-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
#

inherit eutils

DESCRIPTION="Sabayon LXDE Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="!x11-themes/sabayonlinux-artwork
	~x11-themes/sabayon-artwork-core-${PV}"

S="${WORKDIR}/${PN}"

src_install () {
	cd ${S}/lxdm
	dodir /usr/share/lxdm/themes/Sabayon
	insinto /usr/share/lxdm/themes/Sabayon
	doins Sabayon/*
}
