# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit games eutils cmake-utils fdo-mime flag-o-matic

MY_VER=${PV/_p/b}
MY_P=${PN}_$MY_VER
S=${WORKDIR}/${MY_P}

DESCRIPTION="a 3D multiplayer real time strategy game engine"
HOMEPAGE="http://spring.clan-sy.com"
SRC_URI="http://spring.clan-sy.com/dl/${MY_P}_src.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="nomirror"

RDEPEND="
	>=dev-libs/boost-1.35
	media-libs/devil[jpeg,png,opengl]
	>=media-libs/freetype-2.0.0
	>=media-libs/glew-1.4
	>=media-libs/libsdl-1.2.0[X,opengl]
	media-libs/openal
	sys-libs/zlib
	virtual/glu
	virtual/opengl
	dev-lang/python
"

DEPEND="${RDEPEND}
	>=sys-devel/gcc-4.2
	app-arch/zip
	>=dev-util/cmake-2.6.0
"

### where to place content files which change each spring
### release (as opposed to mods, ota-content which go somewhere else)
VERSION_DATADIR="${GAMES_DATADIR}/${PN}"

src_compile () {

	mycmakeargs="${mycmakeargs} -DMARCH_FLAG=$(get-flag march)"
	LIBDIR="$(games_get_libdir)"
	mycmakeargs="${mycmakeargs} -DCMAKE_INSTALL_PREFIX="/usr" \
		-DBINDIR="${GAMES_BINDIR#/usr/}" -DLIBDIR="${LIBDIR#/usr/}" \
		-DDATADIR="${VERSION_DATADIR#/usr/}" -DSPRING_DATADIR="${VERSION_DATADIR}""
	mycmakeargs="${mycmakeargs} -DCMAKE_BUILD_TYPE=RELEASE"
	cmake-utils_src_compile

}

src_install () {
	cmake-utils_src_install
	prepgamesdirs
	ewarn "The location and structure of spring data has changed,"
	ewarn "you may need to adjust your lobby configs."

}


pkg_postinst() {
	fdo-mime_mime_database_update
	games_pkg_postinst
}
