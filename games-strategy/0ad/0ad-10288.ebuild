# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# This ebuild come from roslin overlay

EAPI="3"

inherit eutils wxwidgets games

MY_P="0ad-r${PV}-alpha"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="0 A.D. is a free, real-time strategy game currently under development by Wildfire Games."
HOMEPAGE="http://wildfiregames.com/0ad/"
SRC_URI="mirror://sourceforge/zero-ad/${MY_P}-unix-build.tar.xz
	mirror://sourceforge/zero-ad/${MY_P}-unix-data.tar.xz"

LICENSE="GPL-2 CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug +editor test"

RDEPEND="virtual/opengl
	media-libs/openal
	media-libs/libsdl
	dev-libs/boost
	sys-libs/zlib
	|| ( dev-libs/libgamin app-admin/fam )
	editor? ( x11-libs/wxGTK:2.8 )
	media-libs/devil
	net-libs/enet:1.3
	virtual/jpeg
	media-libs/libpng
	dev-libs/libxml2
	media-libs/libvorbis
	media-libs/libogg
	net-misc/curl"

DEPEND="${RDEPEND}
	dev-lang/nasm
	dev-util/cmake
	app-arch/xz-utils
	app-arch/zip"

RESTRICT="strip mirror"

dir=${GAMES_PREFIX_OPT}/${PN}

pkg_setup() {
	games_pkg_setup
	if use editor ; then
		WX_GTK_VER=2.8 need-wxwidgets unicode
	fi
}

src_compile() {
	UPDATE_ARGS="--with-system-enet"

	if ! use editor ; then
		UPDATE_ARGS="${UPDATE_ARGS} --disable-atlas"
	fi

	cd "${S}/build/workspaces"
	./update-workspaces.sh ${UPDATE_ARGS} || die "update-workspaces.sh failed"
	cd gcc

	TARGETS="pyrogenesis Collada"
	if use test ; then
		TARGETS="${TARGETS} test"
	fi
	if use editor ; then
		TARGETS="${TARGETS} AtlasUI"
	fi
	if use debug ; then
		CONFIG=Debug
	else
		CONFIG=Release
	fi
	CONFIG=${CONFIG} emake ${TARGETS} || die "Can't build"
}

src_test() {
	cd "${S}/binaries/system"
	if use debug ; then
		./test_dbg || die "Tests failed"
	else
		./test || die "Tests failed"
	fi
}

src_install() {
	cd "${S}"/binaries
	insinto "${dir}"
	doins -r data || die "doins -r failed"

	insinto "${dir}"/system

	doins "${S}"/binaries/system/libnvcore.so || die "doins failed"
	doins "${S}"/binaries/system/libnvimage.so || die "doins failed"
	doins "${S}"/binaries/system/libnvmath.so || die "doins failed"
	doins "${S}"/binaries/system/libnvtt.so || die "doins failed"

	if use debug ; then
		doins "${S}"/binaries/system/libmozjs*-ps-debug.so.* || die "doins failed"
		doins "${S}"/binaries/system/libCollada_dbg.so || die "doins failed"
		if use editor ; then
			doins "${S}"/binaries/system/libAtlasUI_dbg.so || die "doins failed"
		fi
		EXE_NAME=pyrogenesis_dbg
	else
		doins "${S}"/binaries/system/libmozjs*-ps-release.so.* || die "doins failed"
		doins "${S}"/binaries/system/libCollada.so || die "doins failed"
		if use editor ; then
			doins "${S}"/binaries/system/libAtlasUI.so || die "doins failed"
		fi
		EXE_NAME=pyrogenesis
	fi

	exeinto "${dir}"/system
	doexe "${S}"/binaries/system/${EXE_NAME} || die "doexe failed"

	games_make_wrapper ${PN} ./system/${EXE_NAME} ${dir}
	doicon "${S}"/build/resources/0ad.png
	make_desktop_entry "${dir}"/system/${EXE_NAME} "0 A.D."

	prepgamesdirs
}
