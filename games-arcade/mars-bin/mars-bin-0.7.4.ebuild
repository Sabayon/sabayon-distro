# Copyright 1999-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# TODO:
# - use games eclass and uniform to that
# - when upstream will grow, use sources (and not precompiled crap)

EAPI=2

inherit eutils

DESCRIPTION="M.A.R.S. a ridiculous shooter"
HOMEPAGE="http://mars-game.sourceforge.net/"
SRC_URI="mirror://sourceforge/mars-game/mars_linux_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}/mars_linux_${PV}"
RESTRICT="strip"

DEPEND=""
RDEPEND="virtual/opengl
	media-libs/flac
	media-libs/freetype
	media-libs/glew
	virtual/jpeg
	media-libs/openal
	media-libs/libogg
	media-libs/libsndfile
	media-libs/libvorbis"

src_unpack() {
	unpack "${A}"
}

src_prepare() {
	einfo "Nothing to prepare"
}

src_install() {

	dodir "/usr/share/${PN}"
	insinto "/usr/share/${PN}"
	doins -r "${S}/data"
	exeinto "/usr/share/${PN}"
	if use amd64; then
		mv "${S}/lib64" "${S}/lib" || die
		mv "${S}/marsshooter64" "${S}/${PN}.bin" || die
	else
		mv "${S}/lib32" "${S}/lib" || die
		mv "${S}/marsshooter32" "${S}/${PN}.bin" || die
	fi
	doexe "${S}/${PN}.bin" || die
	doins -r "${S}/lib"
	echo "MARS_LIBRARY_PATH=\"/usr/share/${PN}/lib\"" > "${S}/99-mars-bin"
	doenvd "${S}/99-mars-bin"

	exeinto /usr/bin
	doexe "${FILESDIR}/${PN}" || die

	mv "${S}/data/tex/icon.png" "${S}/${PN}.png" || die
	doicon "${S}/${PN}.png" || die

	make_desktop_entry "${PN}" "M.A.R.S. is ridiculous" "/usr/share/pixmaps/${PN}.png" "Game" || die

}
