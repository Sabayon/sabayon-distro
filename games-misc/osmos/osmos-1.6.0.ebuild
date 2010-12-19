# Copyright 2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header:
EAPI="2"

inherit games

MY_PN=${PN/o/O}
MY_P="${MY_PN}_${PV}"

DESCRIPTION="Osmos by Hemisphere Games (included in the Humble Indie Bundle)"
HOMEPAGE="http://www.hemispheregames.com/osmos"
SRC_URI="${MY_P}.tar.gz"

LICENSE="EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/freetype
	media-libs/openal
	virtual/opengl
	media-libs/libvorbis"

RESTRICT="fetch strip"

S="${WORKDIR}/${PN/o/O}"

pkg_nofetch() {
    elog "Please purchase ${MY_PN} from ${HOMEPAGE} to play."
	elog "Then place the ${SRC_URI} file into ${DISTDIR} and retry,"
}

src_prepare() {
	cd ${S}
	# We provide our own wrapper
	rm Osmos

	cd Fonts
	einfo "Fixing corrupted FortuneCity font"
	echo -n $'\x5d\x19\xc3\x5c' | dd of=FortuneCity.ttf bs=1 conv=notrunc seek=128
	echo -n $'\x80\x77' | dd of=FortuneCity.ttf bs=1 conv=notrunc seek=138
}

src_compile() { :; }

src_install() {
	cd ${S}

	dodir ${GAMES_PREFIX_OPT}/${PN}/
	cp -R ./* ${D}/${GAMES_PREFIX_OPT}/${PN}/

	if use x86; then
		games_make_wrapper osmos ${GAMES_PREFIX_OPT}/${PN}/${MY_PN}.bin32 ${GAMES_PREFIX_OPT}/${PN}/
		rm ${D}/${GAMES_PREFIX_OPT}/${PN}/${MY_PN}.bin64
	fi
	if use amd64; then
		games_make_wrapper osmos ${GAMES_PREFIX_OPT}/${PN}/${MY_PN}.bin64 ${GAMES_PREFIX_OPT}/${PN}/
		rm ${D}/${GAMES_PREFIX_OPT}/${PN}/${MY_PN}.bin32
	fi

	newicon Icons/64x64.png ${PN}.png
	make_desktop_entry ${PN} Osmos

	prepgamesdirs
}