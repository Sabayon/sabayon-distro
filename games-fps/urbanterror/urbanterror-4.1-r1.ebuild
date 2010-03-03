# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit games toolchain-funcs

DESCRIPTION="Hollywood tactical shooter based on the ioquake3 engine"
HOMEPAGE="http://www.urbanterror.net/"
SRC_URI="ftp://ftp.snt.utwente.nl/pub/games/${PN}/iourbanterror/source/complete/ioUrbanTerrorSource_2007_12_20.zip
	ftp://ftp.snt.utwente.nl/pub/games/${PN}/UrbanTerror_${PV/./}_FULL.zip
	http://files.uaaportal.com/gamefiles/current-version/UrbanTerror_${PV/./}_FULL.zip
	http://upload.wikimedia.org/wikipedia/en/5/56/Urbanterror.svg"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="dedicated openal vorbis"

RDEPEND="net-misc/curl
	vorbis? ( media-libs/libogg media-libs/libvorbis )
	openal? ( media-libs/openal )
	!dedicated? ( media-libs/libsdl[X,opengl] )
	dedicated? ( media-libs/libsdl )
"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_configure() {
	:
}

src_compile() {
	buildit() { use $1 && echo 1 || echo 0 ; }

	if ! use dedicated ; then
		cd "${S}"/ioUrbanTerrorClientSource
		sed -i \
			-e '16s/-Werror //' \
			code/tools/asm/Makefile || die "sed failed"
		emake \
			$(use amd64 && echo ARCH=x86_64) \
			BUILD_CLIENT_SMP=1 \
			BUILD_GAME_SO=0 \
			BUILD_GAME_QVM=0 \
			CC="$(tc-getCC)" \
			DEFAULT_BASEDIR="${GAMES_DATADIR}/${PN}" \
			USE_CODEC_VORBIS=$(buildit vorbis) \
			USE_OPENAL=$(buildit openal) \
			USE_CURL=1 \
			USE_LOCAL_HEADERS=0 \
				|| die "emake client failed"
	fi
	# allways build server
	cd "${S}"/ioUrbanTerrorServerSource
	emake \
		$(use amd64 && echo ARCH=x86_64) \
		BUILD_GAME_SO=0 \
		BUILD_GAME_QVM=0 \
		CC="$(tc-getCC)" \
		DEFAULT_BASEDIR="${GAMES_DATADIR}/${PN}" \
		USE_CODEC_VORBIS=$(buildit vorbis) \
		USE_OPENAL=$(buildit openal) \
		USE_CURL=1 \
		USE_LOCAL_HEADERS=0 \
			|| die "emake server failed"
}

src_install() {
	use amd64 && ARCH=x86_64
	use x86 && ARCH=x86

	if ! use dedicated ; then
			newgamesbin \
				ioUrbanTerrorClientSource/build/release-linux-${ARCH}/ioUrbanTerror-smp.${ARCH} \
				${PN}
			make_desktop_entry ${PN} "UrbanTerror" Urbanterror.svg
	fi
	newgamesbin \
		ioUrbanTerrorServerSource/build/release-linux-${ARCH}/ioUrTded.${ARCH} \
		${PN}-server
	make_desktop_entry ${PN}-server "UrbanTerror Server" Urbanterror.svg

	doicon "${DISTDIR}"/Urbanterror.svg
	cd "${S}"/UrbanTerror/q3ut4
	dodoc readme41.txt
	
	# fix case sensitivity (both upper and lower)
	cp demos/tutorial.dm_68 demos/TUTORIAL.dm_68

	# fix for download map curl issue
	epatch "${FILESDIR}"/curl_fix.patch

	insinto "${GAMES_DATADIR}"/${PN}/q3ut4
	doins -r *.pk3 autoexec.cfg demos/ description.txt mapcycle.txt screenshots/ server.cfg

	prepgamesdirs
}
