# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/compizconfig-python/compizconfig-python-0.6.0.1.ebuild,v 1.6 2007/11/14 13:50:21 hanno Exp $

DESCRIPTION="libcompizconfig python bindings"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=x11-libs/libcompizconfig-${PV}
	>=dev-libs/glib-2.6
	dev-python/pyrex"

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
