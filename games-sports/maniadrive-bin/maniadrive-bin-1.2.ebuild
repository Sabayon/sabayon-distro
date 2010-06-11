# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Ycarus. For new version look here : http://gentoo.zugaina.org/

inherit games eutils

MY_P="ManiaDrive-${PV}-linux-i386"
DESCRIPTION="Trackmania clone"
HOMEPAGE="http://maniadrive.raydium.org"
SRC_URI="mirror://sourceforge/maniadrive/${MY_P}.tar.gz"

RESTRICT="nomirror"

S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="media-libs/libsdl
	amd64? (
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-xlibs
		app-emulation/emul-linux-x86-sdl
	)"

src_install() { 
	dodir ${GAMES_DATADIR}/${PN} ${GAMES_BINDIR}
	mv ${S}/game ${D}${GAMES_DATADIR}/${PN}
	games_make_wrapper mania_drive ./mania_drive.static ${GAMES_DATADIR}/${PN}/game
	games_make_wrapper mania_server ./mania_server.static ${GAMES_DATADIR}/${PN}/game
	fowners root:games "${GAMES_DATADIR}/${PN}/game"
	fperms 2775 "${GAMES_DATADIR}/${PN}/game"
	dodoc README COPYING
}
