# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit qt4

DESCRIPTION="Qt mplayer front end"
HOMEPAGE="http://smplayer.sourceforge.net/"
SRC_URI="http://smplayer.sourceforge.net/download/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"

DEPEND="
	( $(qt4_min_version 4.2.0) )
	media-video/mplayer
	"

RDEPEND="${DEPEND}"

src_compile() {
	SETTINGS="$SETTINGS PREFIX=/usr QMAKE=/usr/bin/qmake"
	emake $SETTINGS || die "emake failed"
}


src_install() {
	einstall PREFIX=${D}/usr || die "make install failed"
	newicon "icons/smplayer_icon64.png" ${PN}.png
	use doc && dodoc Changelog
}
