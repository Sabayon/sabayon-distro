# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils flag-o-matic games

DESCRIPTION="lobby client for spring rts engine"
HOMEPAGE="http://springlobby.info"
SRC_URI="http://www.springlobby.info/tarballs/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="nomirror"
IUSE="bittorrent +sound"

RDEPEND="
	>=x11-libs/wxGTK-2.6.3[X]
	sound? (
		media-libs/sdl-sound
		media-libs/sdl-mixer
	)
	bittorrent? ( >=net-libs/rb_libtorrent-0.14 )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/spring-confgure-fix.patch"
	)

src_configure() {
	econf "$(use_enable bittorrent torrent-system)" \
		"$(use_enable sound)" || die "econf failed"
}

src_compile() {
	append-flags "-DAUX_VERSION=\\\"\"_(Sabayon;$ARCH)\"\\\""
	emake || die "make failed"
}

src_install() {

	dodir /etc/env.d
	dodir /usr/share/pixmaps

	emake install DESTDIR="${D}" || die "make install failed"
	insinto /usr/share/pixmaps
	doins "${S}/src/images/springlobby.svg" \
		|| die "springlobby icon install failed"

	prepgamesdirs
	echo 'XDG_DATA_DIRS="/usr/share/games"' >> 90springlobby
	doenvd 90springlobby

}

