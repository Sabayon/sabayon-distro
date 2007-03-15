# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit autotools flag-o-matic eutils 

DESCRIPTION="Beryl Window Decorator Settings"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"
IUSE=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~amd64 ~ppc"
RESTRICT="nomirror"

src_compile() {
	#--with-lang="${LINGUAS_BERYL}"
	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
