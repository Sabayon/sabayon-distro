# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit linux-mod

DESCRIPTION="Agere ET131x ethernet driver"
HOMEPAGE="http://dadams1969.googlepages.com/et131xkernelmodule"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
DEPEND="sys-apps/net-tools"

MODULE_NAMES="et131x(net:)"
BUILD_TARGETS="modules"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KSRC=${KV_DIR} KERNEL_PATH=${KV_DIR}"
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-2.6.21.patch
}

src_install() {
	linux-mod_src_install
	dodoc README.doc TODO MODULE-PARAMETER.txt
}
