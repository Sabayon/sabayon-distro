# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit kde eutils flag-o-matic

DESCRIPTION="A modified system information page for konqi from Suse"
HOMEPAGE="http://opensuse.org"
SRC_URI="http://download.tuxfamily.org/kiosysinfo/Sources/kio-sysinfo-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="kdeenablefinal"
SLOT="0"
RDEPEND="${DEPEND}"
S=${WORKDIR}/${P}

RDEPEND="
	=kde-base/kdelibs-3.5*
	|| ( ( =kde-base/kdebase-kioslaves-3.5* ) =kde-base/kdebase-3.5* )
	<x11-libs/qt-4
	sys-apps/hwinfo
	>=sys-apps/dbus-1.0
	>=sys-apps/hal-0.5
	"
DEPEND="${RDEPEND}"

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
