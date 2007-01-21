# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="Beryl KDE Window Decorator"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://sabayonlinux.org/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""
RESTRICT="nomirror"

DEPEND="~x11-wm/beryl-core-${PV}"

need-kde 3.5
