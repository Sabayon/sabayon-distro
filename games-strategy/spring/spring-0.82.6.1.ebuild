# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit cmake-utils eutils fdo-mime flag-o-matic games

DESCRIPTION="a 3D multiplayer real time strategy game engine"
HOMEPAGE="http://springrts.com"
SRC_URI="mirror://sourceforge/springrts/${PF/-/_}_src.tar.lzma"
S="${WORKDIR}/${PF/-/_}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug java custom-cflags gml headless"
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
	java? ( virtual/jdk )
"

DEPEND="${RDEPEND}
	>=sys-devel/gcc-4.1
	app-arch/p7zip
	>=dev-util/cmake-2.6.0
"
### gcc 4.4 dependency is bad, but 4.3 causes desync problems

### where to place content files which change each spring release (as opposed to mods, ota-content which go somewhere else)
VERSION_DATADIR="${GAMES_DATADIR}/${PN}"

src_prepare() {
	if ! use gml ; then
		epatch "${FILESDIR}/no_gml.patch"
	fi


	if ! use headless ; then
		epatch "${FILESDIR}/no_headless.patch"
	fi
}

src_configure() {
	if ! use custom-cflags ; then
		strip-flags
	else
		mycmakeargs="${mycmakeargs} -DMARCH_FLAG=$(get-flag march)"
	fi

	if ! use java ; then
		mycmakeargs="${mycmakeargs} -DAIINTERFACES=NATIVE"
	fi

	LIBDIR="$(games_get_libdir)"
	mycmakeargs="${mycmakeargs} -DCMAKE_INSTALL_PREFIX=/usr -DBINDIR=${GAMES_BINDIR#/usr/} -DLIBDIR=${LIBDIR#/usr/} 
-DDATADIR=${VERSION_DATADIR#/usr/}"
	if use debug ; then
		CMAKE_BUILD_TYPE="DEBUG"
	else
		CMAKE_BUILD_TYPE="RELEASE"
	fi

	cmake-utils_src_configure
}

src_compile () {
	cmake-utils_src_compile
}

src_install () {
	cmake-utils_src_install

	prepgamesdirs

	if use custom-cflags ; then
		ewarn "You decided to use custom CFLAGS. This may be save, or it may cause your computer to desync more or less often. If you experience 
desyncs, disable it before doing any bugreport. If you don't know what you are doing, *disable custom-cflags*."
	fi
}

pkg_postinst() {
	fdo-mime_mime_database_update
	games_pkg_postinst
}
