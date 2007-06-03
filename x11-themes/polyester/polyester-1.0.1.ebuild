# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="Widget style + kwin decoration both aimed to be a good balance between eye candy and simplicity."
HOMEPAGE="http://www.kde-look.org/content/show.php?content=27968"
SRC_URI="http://www.notmart.org/files/${P}.tar.bz2"
RESTRICT=nomirror

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="|| ( kde-base/kwin kde-base/kdebase )"

need-kde 3.2
