# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Animal Tracks by Andrew D. Taylor"
HOMEPAGE="http://www.dafont.com/animal-tracks.font"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.lzma"

EAPI=2

LICENSE="animal-tracks"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""
RESTRICT="mirror"

DEPEND=""

S=${WORKDIR}

src_unpack() {
unpack ${A}
}

src_install() {
	dodir /usr/share/fonts
	cp "${WORKDIR}"/ANIMT___.TTF "${D}"/usr/share/fonts || die "Copy Failed"
}
