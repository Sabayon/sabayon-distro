# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Development library for simulation games"
HOMEPAGE="http://www.simgear.org/"
SRC_URI="mirror://simgear/Source/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="subversion"

RDEPEND=">=dev-games/openscenegraph-2.9[png]
	dev-libs/boost
	media-libs/openal
	media-libs/freealut
	subversion? ( dev-vcs/subversion )"
DEPEND="${RDEPEND}"

DOCS=(NEWS AUTHORS)

src_configure() {
	econf \
	$(use_with subversion libsvn)
}
