# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="The Evil Red Windows Decoration for KDE3 (taken from Human Blue)"
HOMEPAGE="http://www.kde-look.org/content/show.php/Human+Blue?content=48318"
SRC_URI="http://www.sabayonlinuxdev.com/distfiles/x11-themes/${PN}/${P}.tar.bz2"
RESTRICT="nomirror"

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="x86 amd64 ppc ppc64"
IUSE=""

DEPEND="|| ( kde-base/kwin kde-base/kdebase )"

need-kde 3.2
