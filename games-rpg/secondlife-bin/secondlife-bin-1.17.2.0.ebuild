# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

MY_P="SecondLife_i686_${PV//./_}"

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"
SRC_URI="http://secondlife.com/downloads/viewer/${MY_P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"

dir="${GAMES_PREFIX_OPT}/secondlife"
QA_EXECSTACK="${dir:1}/bin/do-not-directly-run-secondlife-bin
	${dir:1}/lib/libGLU.so.1
	${dir:1}/lib/libkdu_v42R.so
	${dir:1}/lib/libcrypto.so.0.9.7
	${dir:1}/lib/libfmod-3.75.so"
QA_TEXTRELS="${dir:1}/lib/libfreetype.so.6
	${dir:1}/lib/libcrypto.so.0.9.7
	${dir:1}/lib/libGLU.so.1
	${dir:1}/lib/libkdu_v42R.so
	${dir:1}/lib/libfmod-3.75.so
	${dir:1}/lib/libelfio.so"

RDEPEND="sys-libs/glibc
	media-fonts/kochi-substitute
	x86? ( 
		x11-libs/libX11
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libXext
		dev-libs/libgcrypt
		dev-libs/libgpg-error
		dev-libs/openssl
		media-libs/freetype
		media-libs/libogg
		media-libs/libsdl
		media-libs/libvorbis
		net-libs/gnutls
		net-misc/curl
		sys-libs/zlib
		virtual/glu
		virtual/opengl
	)
	amd64? (
		app-emulation/emul-linux-x86-sdl
		app-emulation/emul-linux-x86-gtklibs
	)"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}

	cd "${S}"
	rm unicode.ttf
}

src_install() {
	exeinto "${dir}"
	doexe launch_url.sh linux-crash-logger.bin secondlife || die
	rm -rf launch_url.sh linux-crash-logger.bin secondlife

	exeinto "${dir}"/bin
	doexe bin/do-not-directly-run-secondlife-bin || die
	rm -rf bin

	exeinto "${dir}"/lib
	doexe lib/* || die
	rm -rf lib

	insinto "${dir}"
	doins -r * || die "doins * failed"

	dosym /usr/share/fonts/kochi-substitute/kochi-mincho-subst.ttf "${dir}"/unicode.ttf

	games_make_wrapper secondlife-bin ./secondlife "${dir}" "${dir}"/lib
	newicon secondlife.ico secondlife-bin.ico
	make_desktop_entry secondlife-bin "Second Life(bin)" secondlife-bin.ico

	prepgamesdirs
}
