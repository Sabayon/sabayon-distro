# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="Simple and Cute KDE Windows Decoration"
HOMEPAGE="http://www.kde-look.org/content/show.php?content=32099"
SRC_URI="http://www.sabayonlinuxdev.com/distfiles/x11-themes/alphacube/Alphacube-${PV}.tar.bz2"
RESTRICT=nomirror

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="|| ( kde-base/kwin kde-base/kdebase )"

need-kde 3.2
