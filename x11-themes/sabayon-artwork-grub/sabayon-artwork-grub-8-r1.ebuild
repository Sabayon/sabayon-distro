# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2
#

EAPI=4

inherit base

DESCRIPTION="Sabayon GRUB2 background images"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {
	cd "${S}/images"
	dodir /usr/share/grub
	insinto /usr/share/grub
	doins default-splash.png
}
