# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Compiz Configuration System (git)"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="dev-libs/libxml2
	~x11-wm/compiz-${PV}"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc TODO || "dodoc failed"
}
