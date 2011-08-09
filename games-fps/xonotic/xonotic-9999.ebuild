# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils games toolchain-funcs git-2

MY_PN="${PN^}"
DESCRIPTION="Fork of Nexuiz, Deathmatch FPS based on DarkPlaces, an advanced Quake 1 engine"
HOMEPAGE="http://www.xonotic.org/"
BASE_URI="git://git.xonotic.org/${PN}/"
EGIT_REPO_URI="${BASE_URI}${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa crypt debug dedicated opengl sdl"

UIRDEPEND="
	media-libs/libogg
	media-libs/libtheora
	media-libs/libvorbis
	media-libs/libmodplug
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXxf86dga
	x11-libs/libXxf86vm
	virtual/opengl
	media-libs/freetype:2
	~games-fps/xonotic-data-9999[client]
	alsa? ( media-libs/alsa-lib )
	sdl? ( media-libs/libsdl[X,audio,joystick,opengl,video,alsa?] )
"
# s3tc? ( dev-libs/libtxc_dxtn )
UIDEPEND="
	x11-proto/xextproto
	x11-proto/xf86dgaproto
	x11-proto/xf86vidmodeproto
	x11-proto/xproto
"
RDEPEND="
	sys-libs/zlib
	virtual/jpeg
	media-libs/libpng
	net-misc/curl
	~dev-libs/d0_blind_id-${PV}[crypt?]
	~games-fps/xonotic-data-9999
	opengl? ( ${UIRDEPEND} )
	!dedicated? ( !opengl? ( ${UIRDEPEND} ) )
"
DEPEND="${RDEPEND}
	opengl? ( ${UIDEPEND} )
	!dedicated? ( !opengl? ( ${UIDEPEND} ) )
"

src_unpack() {
	# root
	git-2_src_unpack

	# Engine
	unset EGIT_MASTER EGIT_BRANCH EGIT_COMMIT EGIT_PROJECT EGIT_DIR
	EGIT_REPO_URI="${BASE_URI}darkplaces.git" \
	EGIT_SOURCEDIR="${S}/darkplaces" \
	EGIT_BRANCH="div0-stable" \
	git-2_src_unpack
}

src_prepare() {
	# for darkplaces
	tc-export CC

	# use system libs
	rm -rf misc/buildfiles/

	# Engine
	pushd darkplaces
	sed -i \
		-e "/^EXE_/s:darkplaces:${PN}:" \
		-e "s:-O3:${CFLAGS}:" \
		-e "/-lm/s:$: ${LDFLAGS}:" \
		-e '/^STRIP/s/strip/true/' \
		makefile.inc || die "sed failed"

	if use !alsa; then
		sed -e "/DEFAULT_SNDAPI/s:ALSA:OSS:" \
			-i makefile || die "sed failed"
	fi
	popd
}

src_compile() {
	# Engine
	pushd darkplaces
	if use debug; then
		ENGINEOPTS="debug"
	else
		ENGINEOPTS="release"
	fi
	ENGINEOPTS+=" DP_LINK_TO_LIBJPEG=1 DP_FS_BASEDIR=${GAMES_DATADIR}/${PN}"

	if use opengl || ! use dedicated; then
		emake cl-${ENGINEOPTS} || die "emake cl-${ENGINEOPTS} failed"
		if use sdl; then
			emake sdl-${ENGINEOPTS} || die "emake sdl-${ENGINEOPTS} failed"
		fi
	fi

	if use dedicated; then
		emake sv-${ENGINEOPTS} || die "emake sv-${ENGINEOPTS} failed"
	fi
	popd
}

src_install() {
	# Engine & docs
	pushd darkplaces
	if use opengl || use !dedicated; then
		dogamesbin ${PN}-glx || die "dogamesbin glx failed"
		newicon ../misc/logos/${PN}_icon.svg ${PN}.svg
		make_desktop_entry ${PN}-glx "${MY_PN} (GLX)"

		if use sdl; then
			dogamesbin ${PN}-sdl || die "dogamesbin sdl failed"
			make_desktop_entry ${PN}-sdl "${MY_PN} (SDL)"
			dosym ${PN}-sdl "${GAMES_BINDIR}"/${PN}
		else
			dosym ${PN}-glx "${GAMES_BINDIR}"/${PN}
		fi
	fi

	if use dedicated; then
		dogamesbin ${PN}-dedicated || die "dogamesbin dedicated failed"
	fi
	popd

	dodoc Docs/*.txt
	dohtml -r readme.html Docs

	insinto "${GAMES_DATADIR}/${PN}"

	# public key for d0_blind_id
	doins key_0.d0pk || die

	if use dedicated; then
		doins -r server || die "doins server failed"
	fi

	prepgamesdirs
}
