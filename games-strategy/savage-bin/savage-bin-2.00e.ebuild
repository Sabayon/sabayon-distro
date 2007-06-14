# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/savage-bin/savage-bin-2.00e.ebuild,v 1.1 2006/10/13 14:23:25 wolf31o2 Exp $

inherit eutils games

SEP_URI="http://www.notforidiots.com/autoupdater/"
BASE_URI="http://downloads.s2games.com/online_orders/"

DESCRIPTION="Unique mix of strategy and FPS"
HOMEPAGE="http://www.s2games.com/savage/"
#SRC_URI="${BASE_URI}/savage_linux.sh.gz
#		mirror://liflg/savage_${PV}-english.update.run
#		${SEP_URI}/SEP-3T.tar.gz
SRC_URI="http://www.happypuppy.com/s2games/Savage_with_sep3t.run
		${SEP_URI}/SEP-3T_3T+-r2.tar.gz
		!sse? ( ${SEP_URI}/SEP-2C-noSSE.tar.gz )"
#		doc? (${MANUAL_URI})"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="sse" #dedicated
RESTRICT="mirror strip"

DEPEND=""
RDEPEND=""

S=${WORKDIR}

dir=${GAMES_PREFIX_OPT}/savage
Ddir=${D}/${dir}

QA_TEXTRELS="${dir:1}/libs/libfmod.so
	${dir:1}/libs/libfmod-3.63.so
	${dir:1}/libs/libfmod-3.75.so"
QA_EXECSTACK="${dir:1}/libs/libfmod.so
	${dir:1}/libs/libfmod-3.75.so"

src_unpack() {
	unpack_makeself Savage_with_sep3t.run
	unpack ./savage.tar.bz2
	unpack ./graveyard.tar.bz2
	unpack SEP-3T_3T+-r2.tar.gz
	if use !sse;then
		unpack SEP-2C-noSSE.tar.gz
	fi
	rm -rf bin setup.* savage.tar.bz2 graveyard.tar.bz2 autoupdater update*
}

src_install() {
	exeinto "${dir}"
	insinto "${dir}"
	doins -r "${S}"/*
	doexe silverback.bin dedicated_server.bin
	touch "${Ddir}"/scripts.log
	fperms ug+w "${dir}"/scripts.log

	# Here, we default to the best resolution.
	sed -i \
		's/setsave vid_mode 4/setsave vid_mode 1/' \
		"${Ddir}"/game/startup.cfg

	newicon icon.xpm savage.xpm
	games_make_wrapper savage "./silverback.bin set mod game" ${dir} ${dir}/libs
	make_desktop_entry savage "Savage: Battle For Newerth" savage.xpm

	games_make_wrapper savage-editor "./silverback.bin set mod editor" ${dir} ${dir}/libs
	make_desktop_entry savage-editor "Savage Editor" savage.xpm

	games_make_wrapper savage-graveyard "./silverback.bin set mod graveyard" ${dir} ${dir}/libs
	make_desktop_entry savage-graveyard "Savage: Graveyard Mod" savage.xpm

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	elog " USE CDKEY:00000000000000000000 to activate the game"
	echo
	elog "To play the game, use:"
	elog " savage"
	echo
}
