# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit distutils

DESCRIPTION="Virt-Manager application helper"
HOMEPAGE="http://virt-manager.et.redhat.com"
SRC_URI="http://virt-manager.et.redhat.com/download/sources/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=app-emulation/libvirt-0.2.0
	dev-lang/python"

DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
}

src_install() {
        distutils_src_install
}
