# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/compizconfig-backend-kconfig/compizconfig-backend-kconfig-0.6.0.ebuild,v 1.5 2007/11/01 01:08:14 tester Exp $

inherit kde

DESCRIPTION="libcompizconfig kde config backend"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=x11-wm/compiz-0.6.0
	>=x11-libs/libcompizconfig-0.6.0"

need-kde 3.5
