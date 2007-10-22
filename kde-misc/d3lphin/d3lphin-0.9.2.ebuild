# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/d3lphin/d3lphin-0.9.2.ebuild,v 1.1 2007/10/04 23:22:09 rgreening Exp $

inherit kde

DESCRIPTION="A file manager for KDE focusing on usability."
HOMEPAGE="https://marrat.homelinux.org/D3lphin"
SRC_URI="http://distfiles.gentoo-xeffects.org/d3lphin/d3lphin-0.9.2.tar.gz"

KEYWORDS="~amd64 ~x86"

SLOT="0"
LICENSE="GPL-2"
IUSE="kdeenablefinal"

need-kde 3.5

PATCHES="${FILESDIR}/${P}-custom_terminal.diff"
