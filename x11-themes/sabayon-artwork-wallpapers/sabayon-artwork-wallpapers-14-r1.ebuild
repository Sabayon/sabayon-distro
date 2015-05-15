# Copyright 1999-2015 Sabayon
# Distributed under the terms of the GNU General Public License v2
#

EAPI=5
inherit eutils sabayon-artwork

DESCRIPTION="Official Sabayon Linux Wallpapers Artwork"
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
	# Wallpaper
	cd "${S}"/background || die
	insinto /usr/share/backgrounds
	doins *.png *.jpg
	newins sabayonlinux.png sabayonlinux-nvidia.png
}

pkg_postinst() {
	einfo "Please report bugs or glitches to"
	einfo "http://bugs.sabayon.org"
}
