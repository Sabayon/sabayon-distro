# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ARTS_REQUIRED="never"
NEED_KDE="3.5"

inherit kde

DESCRIPTION="Compizconfig Kconfig Backend"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="~x11-libs/libcompizconfig-${PV}
	~x11-wm/compiz-${PV}"

pkg_postinst() {
	kde_pkg_postinst
}
