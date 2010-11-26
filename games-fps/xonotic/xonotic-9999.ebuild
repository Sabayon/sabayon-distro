# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils games toolchain-funcs check-reqs git

MY_PN="${PN^}"
DESCRIPTION="Fork of Nexuiz, Deathmatch FPS based on DarkPlaces, an advanced Quake 1 engine"
HOMEPAGE="http://www.xonotic.org/"
BASE_URI="git://git.${PN}.org/${PN}/"
EGIT_REPO_URI="${BASE_URI}${PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa debug dedicated opengl sdl +zip"

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
	alsa? ( media-libs/alsa-lib )
	sdl? ( media-libs/libsdl[X,audio,joystick,opengl,video,alsa?] )
	"
UIDEPEND="
	x11-proto/xextproto
	x11-proto/xf86dgaproto
	x11-proto/xf86vidmodeproto
	x11-proto/xproto
	"
RDEPEND="
	sys-libs/zlib
	media-libs/jpeg
	media-libs/libpng
	net-misc/curl
	opengl? ( ${UIRDEPEND} )
	!dedicated? ( !opengl? ( ${UIRDEPEND} ) )
	"
DEPEND="${RDEPEND}
	zip? ( app-arch/p7zip )
	opengl? ( ${UIDEPEND} )
	!dedicated? ( !opengl? ( ${UIDEPEND} ) )
	"

pkg_setup() {
	ewarn "You need 1,5 Gb diskspace for distfiles."
	if use dedicated && use !opengl; then
		CHECKREQS_DISK_BUILD="1500"
	else
		if use zip; then
			CHECKREQS_DISK_BUILD="2650"
			CHECKREQS_DISK_USR="910"
		else
			CHECKREQS_DISK_BUILD="4800"
			CHECKREQS_DISK_USR="2400"
		fi
	fi
	check_reqs
}

git_pk3_unpack() {
	EGIT_REPO_URI="${BASE_URI}xonotic-${1}.pk3dir.git"
	EGIT_PROJECT="${PN}-${1}.pk3dir"
	S+="/data/${PN}-${1}.pk3dir"
	git_fetch
	S="${WORKDIR}/${P}"
}

src_unpack() {
	# root
	git_src_unpack

	# Engine
	EGIT_REPO_URI="${BASE_URI}darkplaces.git"
	EGIT_PROJECT="darkplaces"
	S+="/darkplaces"
	# comment next line if you prefer unstable
	EGIT_BRANCH="div0-stable" \
	git_fetch
	S="${WORKDIR}/${P}"

	# QC compiler
	EGIT_REPO_URI="git://github.com/Blub/qclib.git"
	EGIT_PROJECT="qclib"
	S+="/fteqcc"
	git_fetch
	S="${WORKDIR}/${P}"

	# Data
	git_pk3_unpack data
	git_pk3_unpack maps
	# needed only for client
	if use opengl || use !dedicated; then
		git_pk3_unpack music
		git_pk3_unpack nexcompat
	else
		rm -rf "${S}/data/font-dejavu.pk3dir" || die "rm failed"
	fi
}

src_prepare() {
	# for darkplaces and fteqcc
	tc-export CC

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

	# rebranding, suddenly it works fine
	for i in nexuiz.*; do
		mv -v "${i}" "${i/nexuiz/${PN}}" || die "mv failed"
	done
	sed -i \
		-e "s/nexuiz/${PN}/g" \
		-e "s/Nexuiz/${PN^}/g" \
		-e "s/NEXUIZ/${PN^^}/g" \
		$(find -type f ! -name '*makefile*') || die "sed failed"
	popd

	# QC compiler
	pushd fteqcc
	sed -i \
		-e '/^CC/d' \
		-e "s: -O3 : :g" \
		-e "s: -s : :g" \
		-e 's/-o fteqcc.bin/$(LDFLAGS) -o fteqcc.bin/' \
		Makefile || die "sed failed"
	popd

	# Data
	if use dedicated && use !opengl; then
		pushd data
		rm -rf \
			xonotic-data.pk3dir/gfx \
			xonotic-data.pk3dir/particles \
			xonotic-data.pk3dir/sound/cyberparcour01/rocket.txt \
			xonotic-data.pk3dir/textures \
			xonotic-maps.pk3dir/textures \
			|| die "rm failed"
		rm -f \
			$(find -type f -name '*.jpg') \
			$(find -type f -name '*.png' ! -name 'sky??.png') \
			$(find -type f -name '*.svg') \
			$(find -type f -name '*.tga') \
			$(find -type f -name '*.wav') \
			$(find -type f -name '*.ogg') \
			$(find -type f -name '*.ase') \
			$(find -type f -name '*.map') \
			$(find -type f -name '*.zym') \
			$(find -type f -name '*.obj') \
			$(find -type f -name '*.blend') \
			|| die "rm failed"
		find -type d \
			-exec rmdir '{}' &>/dev/null \;
		sed -i \
			-e '/^qc-recursive:/s/menu.dat//' \
			xonotic-data.pk3dir/Makefile || die "sed failed"
		popd
	fi
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

	# QC compiler
	pushd fteqcc
	emake BASE_CFLAGS="${CFLAGS} -Wall" || die "emake fteqcc failed"
	popd

	# Data
	pushd data/xonotic-data.pk3dir
	emake \
		FTEQCC="${S}/fteqcc/fteqcc.bin" \
		FTEQCCFLAGS_WATERMARK='' \
		|| die "emake data.pk3 failed"
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

	if use dedicated; then
		doins -r server || die "doins server failed"
	fi

	# Data
	cd data
	rm -rf \
		$(find -name '.git*') \
		$(find -type d -name '.svn') \
		$(find -type d -name 'qcsrc') \
		$(find -type f -name '*.sh') \
		$(find -type f -name '*.pl') \
		$(find -type f -name 'Makefile') \
		|| die "rm failed"
	if use zip; then
		for d in *.pk3dir; do
			pushd "${d}"
			a="${d#xonotic-}"
			7za a -tzip -mx=9 "../${a%dir}" . || die "zip failed"
			popd
			rm -rf "${d}" || die "rm failed"
		done
	fi
	insinto "${GAMES_DATADIR}/${PN}/data"
	doins -r . || die "doins data failed"

	prepgamesdirs
}
