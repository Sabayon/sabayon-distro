# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-fps/nexuiz/nexuiz-2.0.ebuild,v 1.3 2006/06/28 21:57:53 wolf31o2 Exp $

inherit eutils flag-o-matic games

MY_PV=${PV//./}
MY_PN="Nexuiz"
MY_P=${PN}-${MY_PV}

DESCRIPTION="Deathmatch FPS based on DarkPlaces, an advanced Quake 1 engine"
HOMEPAGE="http://www.nexuiz.com"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip
	http://www.alientrap.org/Releases/${MY_P}.zip"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="alsa dedicated opengl oss sdl"

UIRDEPEND="alsa? ( media-libs/alsa-lib )
	media-libs/libogg
	media-libs/libvorbis
	|| (
		(
			x11-libs/libX11
			x11-libs/libXau
			x11-libs/libXdmcp
			x11-libs/libXext
			x11-libs/libXxf86dga
			x11-libs/libXxf86vm )
		virtual/x11 )"
UIDEPEND="|| (
	(
		x11-proto/xextproto
		x11-proto/xf86dgaproto
		x11-proto/xf86vidmodeproto
		x11-proto/xproto )
	virtual/x11 )"
RDEPEND="media-libs/jpeg
	sys-libs/glibc
	sys-libs/zlib
	sdl? ( media-libs/libsdl ${UIRDEPEND} )
	opengl? ( virtual/opengl ${UIRDEPEND} )
	!dedicated? ( !sdl? ( !opengl? ( virtual/opengl ${UIRDEPEND} ) ) )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	app-arch/unzip
	sdl? ( media-libs/libsdl ${UIDEPEND} )
	opengl? ( virtual/opengl ${UIDEPEND} )
	!dedicated? ( !sdl? ( !opengl? ( virtual/opengl ${UIDEPEND} ) ) )"

S=${WORKDIR}/darkplaces
# This is the right dir, so that e.g. "darkplaces -game nexuiz" will work
dir=${GAMES_DATADIR}/quake1
exe=${PN}

default_client() {
	if use opengl || $( ! use dedicated && ! use sdl ) ; then
		# Build default client
		return 0
	fi
	return 1
}

pkg_setup() {
	games_pkg_setup

	if default_client && ! use opengl ; then
		einfo "Defaulting to OpenGL client"
	fi
}

src_unpack() {
	unpack ${A}

	local f
	for f in "${MY_PN}"/sources/*.zip ; do
		unpack ./"${f}"
	done

	rm "${MY_PN}"/Docs/server/{*_mac.*,*.bat}

	cd "${S}"
	# Make the game automatically look in the correct data directory
	sed -i fs.c \
		-e "s:strcpy(fs_basedir, \"\"):strcpy(fs_basedir, \"${dir}\"):" \
		-e "s:gamedirname1:\"${PN}\":" \
		|| die "sed fs.c failed"

	# Only additional CFLAGS optimization is the -march flag
	local march=$(get-flag -march)
	sed -i makefile.inc \
		-e '/^CC=/d' \
		-e "s:-lasound:$(pkg-config --libs alsa):" \
		-e "s:CPUOPTIMIZATIONS=:CPUOPTIMIZATIONS=${march}:" \
		-e "s:strip:#strip:" \
		|| die "sed makefile.inc failed"

	# Reduce SDL audio buffer, to fix latency
	sed -i "s:requested->speed / 20.0:512:" snd_sdl.c \
		|| die "sed snd_sdl.c failed"

	# Default sound is alsa.
	if ! use alsa ; then
		if use oss ; then
			sed -i "s:DEFAULT_SNDAPI=ALSA:DEFAULT_SNDAPI=OSS:" makefile \
				|| die "sed oss failed"
		else
			sed -i "s:DEFAULT_SNDAPI=ALSA:DEFAULT_SNDAPI=NULL:" makefile \
				|| die "sed null failed"
		fi
	fi
}

src_compile() {
	if default_client ; then
		emake cl-${PN} || die "emake cl-${PN} failed"
	fi

	if use sdl ; then
		emake sdl-${PN} || die "emake sdl-${PN} failed"
	fi

	if use dedicated ; then
		emake sv-${PN} || die "emake sv-${PN} failed"
	fi
}

src_install() {
	if default_client || use sdl ; then
		newicon darkplaces72x72.png ${PN}.png
	fi

	if default_client ; then
		newgamesbin ${PN}-glx ${PN} \
			|| die "newgamesbin opengl failed"
		make_desktop_entry ${PN} Nexuiz ${PN}.png
	fi

	if use sdl ; then
		dogamesbin ${PN}-sdl \
			|| die "dogamesbin sdl failed"
		make_desktop_entry ${PN}-sdl "Nexuiz (SDL)" ${PN}.png
	fi

	if use dedicated ; then
		newgamesbin ${PN}-dedicated ${PN}-ded \
			|| die "newgamesbin ded failed"
		games_make_wrapper ${PN}-ded ./${PN}-ded "${dir}"
	fi

	cd "${WORKDIR}/${MY_PN}"
	insinto "${dir}/${PN}"
	doins -r data/* || die "doins data failed"

	dodoc Docs/*.txt
	dohtml Docs/*.{htm,html}
	docinto server
	dodoc Docs/server/*

	prepgamesdirs
}
