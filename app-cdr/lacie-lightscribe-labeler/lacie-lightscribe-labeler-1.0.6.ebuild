# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit rpm

DESCRIPTION="LaCie LightScribe Labeler 4L"
HOMEPAGE="http://www.lacie.com/us/products/product.htm?pid=10803"
SRC_URI="http://www.lacie.com/download/drivers/4L-1.0-r6.i586.rpm"
LICENSE=""
SLOT="0"
KEYWORDS="-amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"
DEPEND=""
RDEPEND="virtual/libc
	=virtual/libstdc++-3*
	sys-devel/gcc
	dev-libs/libxml2
	media-libs/freetype
	media-libs/fontconfig
	sys-libs/zlib
	|| ( x11-libs/libX11 virtual/x11 )
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrender
	x11-libs/libXrandr
	app-cdr/lightscribe
	"

src_unpack() {
	rpm_src_unpack
}

src_compile() { :; }

src_install() {
	cd ${WORKDIR}

	# we don't like /usr/4L, binary
	# stuff shall go to /opt.
	dodir   /opt/${PN}
	insinto /opt/${PN}
	exeinto /opt/${PN}
	doexe  ./usr/4L/4L-cli
	doexe  ./usr/4L/4L-gui
	# 4L-gui looks for translations in /usr/4L
	# and the current directory, so we use a
	# wrapper script for 4L-gui which changes
	# to the installation directory first, so
	# 4L-gui can find its translations
	{
		echo '#!/bin/sh';
		echo "cd /opt/${PN} && exec ./4L-gui"
	} >${T}/4L-gui-wrapper.sh
	doexe  ${T}/4L-gui-wrapper.sh
	doexe  ./usr/4L/lacie_website.sh
	dodir   /opt/${PN}/templates
	insinto /opt/${PN}/templates
	doins  ./usr/4L/templates/*
	dodir   /opt/${PN}/translations
	insinto /opt/${PN}/translations
	doins  ./usr/4L/translations/*
	dodoc  ./usr/4L/doc/4L_User_Manual.pdf
	dosym   /opt/${PN}/4L-cli /usr/bin/4L-cli
	dosym   /opt/${PN}/4L-gui-wrapper.sh /usr/bin/4L-gui
	insinto /usr/share/applications/
	doins   ${FILESDIR}/${PN}.desktop
}
