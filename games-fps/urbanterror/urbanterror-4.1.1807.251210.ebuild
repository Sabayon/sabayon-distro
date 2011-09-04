# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic games toolchain-funcs versionator

DESCRIPTION="Hollywood tactical shooter based on the ioquake3 engine"
HOMEPAGE="http://www.urbanterror.net/
	  http://www.www0.org/w/Optimized_executable;_builds_of_ioq3_engine_for_urt"
MY_VER=$(get_version_component_range 1)$(get_version_component_range 2)
MY_PATCH=$(get_version_component_range 3)-urt-$(get_version_component_range 4)-git-nobumpy
SRC_URI="http://xmw.de/mirror/urbanterror/ioquake3-1807.tar.bz2
	http://www0.org/urt/ioq3-${MY_PATCH}.tar.lzma
	ftp://ftp.snt.utwente.nl/pub/games/${PN}/old/UrbanTerror_${MY_VER}_FULL.zip
	http://upload.wikimedia.org/wikipedia/en/5/56/Urbanterror.svg -> ${PN}.svg"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client +curl openal server speex vanilla vorbis"

COMMON_DEPEND="
	client? (
		media-libs/ftgl
		media-libs/freetype:1
		media-libs/libsdl[X,opengl]
		openal? ( media-libs/openal )
		vorbis? ( media-libs/libogg media-libs/libvorbis )
	)
	curl? ( net-misc/curl )
	speex? ( media-libs/speex ) "
DEPEND="${COMMON_DEPEND}
	app-arch/p7zip
	app-arch/unzip
	dev-util/pkgconfig
	media-libs/netpbm"
RDEPEND="${COMMON_DEPEND}"

S=${WORKDIR}/ioquake3

src_prepare() {
	epatch "${WORKDIR}"/ioq3-${MY_PATCH}.patch
	use vanilla || epatch "${FILESDIR}"/${P}-server-name.patch

	rm -rf code/{FTGL,FT2,SDL12,libs/win{32,64}} || die

	sed -e '/SDL_CFLAGS=/s:--cflags sdl:--cflags freetype2 sdl:' \
		-i Makefile || die

	sed -e 's:include <SDL_opengl.h>:include <SDL/SDL_opengl.h>:' \
		-i code/renderer/qgl.h || die

	# fix case sensitivity and remove shipped binaries
	local my_utdir=${WORKDIR}/UrbanTerror
	mv "${my_utdir}/q3ut4/demos/tutorial.dm_68" \
		"${my_utdir}/q3ut4/demos/TUTORIAL.dm_68" || die
	rm -f "${my_utdir}"/io{UrbanTerror,UrTded,}.{exe,i386,x86_64} || die
}

src_compile() {
	buildit() { use $1 && echo 1 || echo 0 ; }

	emake \
		$(use amd64 && echo ARCH=x86_64 || echo ARCH=i386) \
		BUILD_SERVER=$(buildit server) \
		BUILD_CLIENT=$(buildit client) \
		BUILD_CLIENT_SMP=$(buildit client) \
		CC="$(tc-getCC)" \
		DEFAULT_BASEDIR="${GAMES_DATADIR}/${PN}" \
		USE_CODEC_VORBIS=$(buildit vorbis) \
		USE_OPENAL=$(buildit openal) \
		USE_CURL=$(buildit curl) \
		USE_VOIP=$(buildit speex) \
		USE_INTERNAL_SPEEX=0 \
		USE_INTERNAL_ZLIB=0 \
		USE_LOCAL_HEADERS=0 \
		release || die
	#BASE_CFLAGS="${CFLAGS} -DUSE_ICON -DPRODUCT_VERSION=\\\"$(VERSION)\\\"" \
}

src_install() {
	local my_arch=i386
	use amd64 && my_arch=x86_64

	if use client || use server ; then # just kidding
		insinto /usr/share/pixmaps
		doins "${DISTDIR}"/${PN}.svg || die
	fi

	insinto "${GAMES_DATADIR}"/${PN}/q3ut4
	#doins -r q3ut4/{glsl,textures} || die

	if use client ; then
		newgamesbin build/release-linux-${my_arch}/ioquake3-smp.${my_arch} ${PN} || die
		make_desktop_entry ${PN} "UrbanTerror" ${PN}
	fi

	if use server ; then
		newgamesbin build/release-linux-${my_arch}/ioquake3-smp.${my_arch} ${PN}-dedicated || die
		make_desktop_entry ${PN}-dedicated "UrbanTerror dedicated" ${PN}
		doins dedicated.cfg || die
	fi

	dodoc ChangeLog NOTTODO README TODO {md4,voip}-readme.txt || die

	cd "${WORKDIR}"/UrbanTerror/q3ut4 || die

	doins -r *.pk3 autoexec.cfg demos/ description.txt mapcycle.txt screenshots/ || die

	prepgamesdirs
}
