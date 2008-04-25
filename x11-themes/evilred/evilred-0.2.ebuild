# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="The Evil Red Windows Decoration for KDE3 (taken from Human Blue)"
HOMEPAGE="http://www.kde-look.org/content/show.php/Human+Blue?content=48318"
SRC_URI="http://www.sabayonlinux.org/distfiles/x11-themes/${PN}/${P}.tar.bz2"
RESTRICT="nomirror"

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="x86 amd64 ppc ppc64"
IUSE=""

DEPEND="|| ( =kde-base/kwin-3.5* =kde-base/kdebase-3.5* )"

need-kde 3.2
