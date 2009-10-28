# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit games toolchain-funcs versionator

MY_P="${PN}_v$(delete_all_version_separators $PV)_src"

DESCRIPTION="Action-adventure dungen crawl game"
HOMEPAGE="http://www.asceai.net/meritous/"
SRC_URI="http://www.asceai.net/files/${MY_P}.tar.bz2
	( http://omploader.org/vMTNkZg -> data-dir.patch )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/libsdl
	media-libs/sdl-image
	media-libs/sdl-mixer"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${DISTDIR}"/data-dir.patch
	epatch "${FILESDIR}"/Makefile-flags.patch
	sed -ie 's/gcc/$(CC)/' Makefile || die "sed Makefile failed"
}

src_compile() {
	CFLAGS="${CFLAGS} -DDATA_DIR=\\\"${GAMES_DATADIR}/meritous\\\"" \
	emake CC=$(tc-getCC) default || die
}

src_install() {
	insinto "${GAMES_DATADIR}/meritous"
	doins -r dat/* || die
	dogamesbin meritous || die
	dodoc readme.txt || die
	prepgamesdirs
}
