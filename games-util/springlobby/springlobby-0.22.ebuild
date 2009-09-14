# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic games

DESCRIPTION="lobby client for spring rts engine"
HOMEPAGE="http://springlobby.info"
SRC_URI="http://www.springlobby.info/tarballs/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="nomirror"
IUSE="disable-torrent disable-sound debug"

RDEPEND="
	>=x11-libs/wxGTK-2.6.3[X]
	!disable-sound? (	media-libs/sdl-sound
						media-libs/sdl-mixer )
	!disable-torrent? (	>=net-libs/rb_libtorrent-0.14 )
"
DEPEND="${RDEPEND}
"

src_configure() {
	OPTIONS=""
	if use disable-torrent ; then
		OPTIONS="${OPTIONS} --disable-torrent-system"
	fi
	if use disable-sound ; then
		OPTIONS="${OPTIONS} --disable-sound"
	fi

	egamesconf ${OPTIONS} || die "econf failed"
}

src_compile() {
	append-flags "-DAUX_VERSION=\\\"\"_(Gentoo;$ARCH)\"\\\""
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR=${D}
	prepgamesdirs
	dodir /usr/share/games/icons/hicolor/scalable/apps/
	mv ${D}/usr/share/games/pixmaps/springlobby.svg ${D}/usr/share/games/icons/hicolor/scalable/apps/springlobby.svg
	rm ${D}/usr/share/games/pixmaps/ -fr
	dodir /etc/env.d/
	echo 'XDG_DATA_DIRS="/usr/share/games"' >> ${D}/etc/env.d/99games
}

