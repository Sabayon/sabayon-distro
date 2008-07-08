# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Python modules for dealing with block devices"
HOMEPAGE="http://www.redhat.com"
SRC_URI="http://www.sabayonlinux.org/distfiles/dev-python/${P}.tar.bz2"
IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~x86"
RESTRICT="nomirror"

RDEPEND=">=dev-lang/python-2.4
	sys-fs/dmraid
	>=sys-fs/device-mapper-1.02.17
	sys-devel/gettext
	sys-libs/zlib
"
DEPEND="${RDEPEND}"

src_compile() {
	cd "${S}"
	emake USESELINUX=0 || die "make failed"	
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}

