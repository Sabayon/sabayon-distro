# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/compiz-bcop/compiz-bcop-0.6.0.ebuild,v 1.4 2007/10/25 13:58:39 tester Exp $

DESCRIPTION="Compiz option code generator"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="dev-libs/libxslt"

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS || die "dodoc failed"
}
