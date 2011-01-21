# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="GTK+-based Yahoo! chat client"
SRC_URI="mirror://sourceforge/gyachi/${P}.tar.gz"
HOMEPAGE="http://gyachi.sourceforge.net/"



LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome v4l2"

DEPEND="virtual/libc
		=x11-libs/gtk+-2*
		media-libs/jasper
		dev-libs/expat
		app-crypt/mcrypt
		app-crypt/gpgme
		=gnome-extra/gtkhtml-2*"

RDEPEND="${DEPEND}"
S="${WORKDIR}/${P}"

inherit eutils distutils

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/gyachi.patch
}

src_compile() {
	cd ${S}
	touch AUTHORS COPYING INSTALL NEWS README
	if [ "`uname -a`" != "i386" ]; then
		sed 's/gyvoice//' Makefile.am > Makefile.out
		mv -f Makefile.out Makefile.am
	fi
	autoreconf
	libtoolize --copy --force
	econf
	emake
}

src_install() {
	cd ${S}
	einstall SHAREDDIR=/usr/share/gyache
}
 
