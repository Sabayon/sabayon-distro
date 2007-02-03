# Copyright 2004-2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit eutils

DESCRIPTION="Beryl's vidcap plugin for screen capture"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://sabayonlinux.org/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="~x11-plugins/beryl-plugins-${PV}
	=media-misc/seom-9999"

src_compile() {
	emake || die "make failed"
}

src_install() {
	dodir ${ROOT}/usr/local/share/beryl
	make DESTDIR="${D}" install || die "make install failed"
}
