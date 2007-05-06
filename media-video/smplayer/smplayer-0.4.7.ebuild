# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Qt mplayer front end"
HOMEPAGE="http://smplayer.sourceforge.net/"
SRC_URI="http://smplayer.sourceforge.net/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="kde"

DEPEND="
        >=x11-libs/qt-4.2
	kde? ( >=kde-base/kdelibs-3.5 )
	"

RDEPEND="${DEPEND}
	media-video/mplayer"

src_compile() {

	SETTINGS="$SETTINGS PREFIX=/usr QMAKE=/usr/bin/qmake"
	make prep || die "make prep failed"
	emake $SETTINGS || die "emake failed"
	
}


src_install() {
	einstall PREFIX=${D}/usr || die "make install failed"
	newicon "icons/smplayer_icon64.png" ${PN}.png
}
