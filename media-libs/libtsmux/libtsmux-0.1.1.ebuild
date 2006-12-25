# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: cvill64 Exp $

inherit eutils

HOMEPAGE="http://schrodinger.sourceforge.net/"
DESCRIPTION=""
SRC_URI="http://umn.dl.sourceforge.net/sourceforge/schrodinger/libtsmux-0.1.1.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	"

src_compile() {
	econf || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc README AUTHORS ChangeLog
}
