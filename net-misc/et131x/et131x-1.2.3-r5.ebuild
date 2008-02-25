# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit linux-mod

DESCRIPTION="Agere ET131x ethernet driver"
HOMEPAGE="http://dadams1969.googlepages.com/et131xkernelmodule"
SRC_URI="mirror://sourceforge/${PN}/${P}-1.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
DEPEND="sys-apps/net-tools"

MODULE_NAMES="et131x(net:)"
BUILD_TARGETS="modules"

S=${S}-1

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KSRC=${KV_DIR} KERNEL_DIR=${KV_DIR} KERNEL_PATH=${KV_DIR}"
}

src_unpack() {
	unpack ${A}
	cd ${S}
        epatch ${FILESDIR}/et131x_1.2.3-4.diff
        epatch ${FILESDIR}/${P}-2.6.23.patch
        epatch ${FILESDIR}/${P}-2.6.23-r1.patch
        #epatch ${FILESDIR}/${P}-2.6.23-r2.patch
	epatch ${FILESDIR}/${P}-2.6.24.patch
	# fix KERNEL_VER
	sed -i '/KERNEL_VER :=/ s/.*/KERNEL_VER := '${KV_FULL}'/' Makefile
	# fix KERNEL_DIR
	#sed -i '/KERNEL_DIR :=/ s/.*/KERNEL_DIR := '${KV_DIR}'/' Makefile
}

src_install() {
	linux-mod_src_install
	dodoc README.doc TODO MODULE-PARAMETER.txt
}
