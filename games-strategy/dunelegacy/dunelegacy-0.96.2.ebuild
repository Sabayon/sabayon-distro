# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games


DESCRIPTION="Dune Legacy is an open source clone of Dune 2."
HOMEPAGE="http://dunelegacy.sourceforge.net"
SRC_URI="http://www.myway.de/richieland/${PN}-0.96.2-src.tar.bz2"

LICENSE="GPL-2 or later"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="media-libs/libsdl
	media-libs/sdl-mixer"

DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}-0.96.2

src_install() {
        cd "${S}/src"

	dogamesbin ${PN} || die "dogamesbin failed"

	cd "${S}"

	insinto "${GAMES_DATADIR}"/${PN}
	doins -r data/* || die "doins failed"

	doicon dunelegacy.png
	make_desktop_entry ${PN} "Dune Legacy" dunelegacy.png "Game;StrategyGame;"

	prepgamesdirs
}

pkg_postinst() {
    elog "You will need to copy all Dune 2 PAK files to ${GAMES_DATADIR}/${PN} !"
    elog ""
    elog "At least the following files are needed:"
    elog " - ATRE.PAK"
    elog " - DUNE.PAK"
    elog " - ENGLISH.PAK"
    elog " - FINALE.PAK"
    elog " - HARK.PAK"
    elog " - INTRO.PAK"
    elog " - INTROVOC.PAK"
    elog " - MENTAT.PAK"
    elog " - MERC.PAK"
    elog " - ORDOS.PAK"
    elog " - SCENARIO.PAK"
    elog " - SOUND.PAK"
    elog " - VOC.PAK"
    elog ""
    elog "For playing in german or french you need additionally GERMAN.PAK"
    elog "or FRENCH.PAK."
}

