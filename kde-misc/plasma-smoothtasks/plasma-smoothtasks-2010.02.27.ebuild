# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="2"

KDE_LINGUAS="cs de fr hu pl uk_UA zh_CN"
inherit kde4-base

MY_PV="${PV/\./-}"
MY_PV="${MY_PV/\./-}"
MY_P="smooth-tasks-src-wip-${MY_PV}"

DESCRIPTION="KDE plasmoid. Windows 7 like taskbar, fork of stasks"
HOMEPAGE="http://www.kde-look.org/content/show.php/Smooth+Tasks?content=101586"
SRC_URI="http://www.kde-look.org/CONTENT/content-files/101586-${MY_P}.tar.bz2"
RESTRICT="mirror"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="debug"

DEPEND="
	>=kde-base/libtaskmanager-${KDE_MINIMAL}
"
RDEPEND="${DEPEND}
	>=kde-base/plasma-workspace-${KDE_MINIMAL}
"

S="${WORKDIR}/${MY_P}"