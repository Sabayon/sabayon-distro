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

DEPEND=">=app-emulation/libvirt-0.2.0
	dev-lang/python"


src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-accelerate.patch
	epatch ${FILESDIR}/${P}-features-xml.patch
	epatch ${FILESDIR}/${P}-default-net.patch
	epatch ${FILESDIR}/${P}-urlgrabber-import.patch
}

src_install() {
        distutils_src_install
}
