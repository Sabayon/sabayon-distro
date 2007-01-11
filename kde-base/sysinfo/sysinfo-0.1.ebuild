# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit kde eutils flag-o-matic

DESCRIPTION="A modified system information page for konqi from Suse"
HOMEPAGE="http://opensuse.org"
SRC_URI="http://sabayonlinux.org/distfiles/kde-base/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="kdeenablefinal"

DEPEND="kde-base/kdebase
	x11-libs/qt"

# S=${PN}/work

need-kde 3.5

src_compile() {
        append-flags -fno-inline

	local myconf="$(use_enable kdeenablefinal final)"

	kde_src_compile
}