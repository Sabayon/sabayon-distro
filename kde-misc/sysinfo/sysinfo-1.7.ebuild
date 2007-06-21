# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit kde eutils flag-o-matic

DESCRIPTION="A modified system information page for konqi from Suse"
HOMEPAGE="http://opensuse.org"
SRC_URI="http://sabayonlinux.org/distfiles/kde-misc/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="kdeenablefinal"
SLOT="0"
RDEPEND="${DEPEND}"
S=${WORKDIR}/${P}

DEPEND="
	|| ( >=kde-base/kdebase-3.5.0 >=kde-base/kdebase-meta-3.5.0 )
	<x11-libs/qt-4
	sys-apps/hwinfo
	"

need-kde 3.5

src_unpack() {
	unpack ${A}
	cd ${WORKDIR}
	mv kio-${P} ${P}
}

src_compile() {
        append-flags -fno-inline

	local myconf="$(use_enable kdeenablefinal final)"

	kde_src_compile
}
