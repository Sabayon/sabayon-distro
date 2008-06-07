# Copyright 2006-2008 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="The Human Blue Window Decoration for KDE3"
HOMEPAGE="http://www.kde-look.org/content/show.php/Human+Blue?content=48318"
SRC_URI="http://download.tuxfamily.org/nferko/kde/deco/humanblue-${PV}.tar.bz2"
RESTRICT="nomirror"

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="x86 amd64 ppc ppc64"
IUSE=""

DEPEND="|| ( =kde-base/kwin-3.5* =kde-base/kdebase-3.5* )"

need-kde 3.2

src_compile() {
	kde_src_compile || die "make failed"
}
