# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit nsplugins

DESCRIPTION="Video chat browser plug-in for Google Talk"
SRC_URI="x86? ( http://dl.google.com/linux/direct/google-talkplugin_current_i386.deb )
	amd64? ( http://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb )"
HOMEPAGE="http://www.google.com/chat/video"
IUSE="system-libCg"
SLOT="0"

KEYWORDS="-* ~amd64 ~x86"
LICENSE="UNKNOWN"
RESTRICT="strip mirror"

#from debian control file and ldd
RDEPEND="|| ( media-sound/pulseaudio media-libs/alsa-lib )
	>=sys-libs/glibc-2.4
	media-libs/fontconfig
	media-libs/freetype:2
	virtual/opengl
	media-libs/glew
	dev-libs/glib:2
	x11-libs/gtk+:2
	media-libs/libpng:1.2
	media-libs/libpng:0
	dev-libs/openssl
	x11-libs/libX11
	x11-libs/libXfixes
	x11-libs/libXt
	x11-libs/libxcb
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXxf86vm
	x11-libs/libXdamage
	x11-libs/libxcb
	x11-libs/libdrm
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/pango
	x11-libs/libXi
	dev-libs/atk
	x11-libs/cairo
	x11-libs/libXrandr
	x11-libs/libXcursor
	x11-libs/libXcomposite
	x11-libs/libXrender
	dev-libs/expat
	sys-apps/util-linux
	x11-libs/pixman
	x11-libs/xcb-util
	system-libCg? ( media-gfx/nvidia-cg-toolkit )
	sys-apps/lsb-release
	sys-libs/zlib"

INSTALL_BASE="/opt/google/talkplugin"

[ "${ARCH}" = "amd64" ] && SO_SUFFIX="64" || SO_SUFFIX=""

QA_TEXTRELS="opt/google/talkplugin/libnpgtpo3dautoplugin.so
	opt/google/talkplugin/libnpgoogletalk${SO_SUFFIX}.so"

src_unpack() {
	unpack ${A} ./data.tar.gz ./usr/share/doc/google-talkplugin/changelog.Debian.gz
}

src_install() {
	dodoc ./usr/share/doc/google-talkplugin/changelog.Debian

	cd ".${INSTALL_BASE}"
	exeinto "${INSTALL_BASE}"
	doexe GoogleTalkPlugin libnpgtpo3dautoplugin.so	libnpgoogletalk"${SO_SUFFIX}".so
	inst_plugin "${INSTALL_BASE}"/libnpgtpo3dautoplugin.so
	inst_plugin "${INSTALL_BASE}"/libnpgoogletalk"${SO_SUFFIX}".so

	#install bundled libCg
	if ! use system-libCg; then
		cd lib
		exeinto "${INSTALL_BASE}/lib"
		doexe *.so
	fi
}
