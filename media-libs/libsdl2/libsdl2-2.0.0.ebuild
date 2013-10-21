# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools cmake-multilib

MY_P=SDL2-${PV}
DESCRIPTION="Simple Direct Media Layer"
HOMEPAGE="http://www.libsdl.org"
SRC_URI="http://www.libsdl.org/release/${MY_P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="3dnow alsa altivec +asm aqua fusionsound gles mmx nas opengl oss pulseaudio sse sse2 static-libs +threads tslib +video X xinerama xscreensaver abi_x86_32"

RDEPEND="
	nas? (
		media-libs/nas
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXt
	)
	X? (
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXt
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libXxf86vm
	)
	xinerama? ( x11-libs/libXinerama )
	xscreensaver? ( x11-libs/libXScrnSaver )
	alsa? ( media-libs/alsa-lib )
	fusionsound? ( >=media-libs/FusionSound-1.1.1 )
	pulseaudio? ( >=media-sound/pulseaudio-0.9 )
	gles? ( || ( media-libs/mesa[gles2] media-libs/mesa[gles] ) )
	opengl? ( virtual/opengl )
	tslib? ( x11-libs/tslib )
"

DEPEND="${RDEPEND}
	nas? (
		x11-proto/xextproto
		x11-proto/xproto
	)
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
		x11-proto/xproto
		x11-proto/randrproto
		x11-proto/renderproto
	)
	xinerama? ( x11-proto/xineramaproto )
	xscreensaver? ( x11-proto/scrnsaverproto )
"

DOCS=( BUGS.txt CREDITS.txt README.txt README-SDL.txt TODO.txt WhatsNew.txt )
S=${WORKDIR}/${MY_P}

src_prepare() {
	# https://bugzilla.libsdl.org/show_bug.cgi?id=1431
	epatch "${FILESDIR}"/${P}-static-libs.patch \
		"${FILESDIR}"/${P}-threads.patch
	AT_M4DIR="/usr/share/aclocal acinclude" eautoreconf
}

src_configure() {
	mycmakeargs=(
		# Disable assertion tests.
		-DASSERTIONS=disabled
		# Avoid hard-coding RPATH entries into dynamically linked SDL libraries.
		-DRPATH=NO
		# Disable obsolete and/or inapplicable libraries.
		-DARTS=NO
		-DESD=NO
		$(cmake-utils_use 3dnow 3DNOW)
		$(cmake-utils_use alsa ALSA)
		$(cmake-utils_use altivec ALTIVEC)
		$(cmake-utils_use asm ASSEMBLY)
		$(cmake-utils_use aqua VIDEO_COCOA)
		$(cmake-utils_use fusionsound FUSIONSOUND)
		$(cmake-utils_use gles VIDEO_OPENGLES)
		$(cmake-utils_use mmx MMX)
		$(cmake-utils_use nas NAS)
		$(cmake-utils_use opengl VIDEO_OPENGL)
		$(cmake-utils_use oss OSS)
		$(cmake-utils_use pulseaudio PULSEAUDIO)
		$(cmake-utils_use threads PTHREADS)
		$(cmake-utils_use sse SSE)
		$(cmake-utils_use sse SSEMATH)
		$(cmake-utils_use sse2 SSE2)
		$(cmake-utils_use static-libs SDL_STATIC)
		$(cmake-utils_use tslib INPUT_TSLIB)
		$(cmake-utils_use video VIDEO_DUMMY)
		$(cmake-utils_use X VIDEO_X11)
		$(cmake-utils_use X VIDEO_X11_XCURSOR)
		$(cmake-utils_use xinerama VIDEO_X11_XINERAMA)
		$(cmake-utils_use X VIDEO_X11_XINPUT)
		$(cmake-utils_use X VIDEO_X11_XRANDR)
		$(cmake-utils_use xscreensaver VIDEO_X11_XSCRNSAVER)
		$(cmake-utils_use X VIDEO_X11_XVM)
		#$(cmake-utils_use joystick SDL_JOYSTICK)
	)
	cmake-multilib_src_configure
}

src_install() {
	cmake-multilib_src_install
}
