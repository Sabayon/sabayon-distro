# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

KDE_MINIMAL="4.6"
inherit kde4-base

DESCRIPTION="KWin theme engine that uses Emerald themes"
HOMEPAGE="http://kde-look.org/content/show.php?content=125162"
SRC_URI="http://www.kde-look.org/CONTENT/content-files/125162-${P}.tar.bz2"

LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE="debug"

DEPEND="$(add_kdebase_dep kdelibs)
	$(add_kdebase_dep libkworkspace)
	x11-libs/cairo
"

