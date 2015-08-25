# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#

EAPI=5
inherit eutils sabayon-artwork

DESCRIPTION="Official Sabayon Linux Core Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~arm ~x86 ~amd64"
IUSE=""
RDEPEND="
	!<x11-themes/sabayon-artwork-core-14
"

S="${WORKDIR}/${PN}"

src_install() {
	# Cursors
	cd "${S}"/mouse/entis/cursors || die
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors
	doins -r ./
}

pkg_postinst() {

	einfo "Please report bugs or glitches to"
	einfo "http://bugs.sabayon.org"
}
