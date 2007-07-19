# Copyright 2007-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

DESCRIPTION="a set of tools for updating gentoo config files"
HOMEPAGE="http://developer.berlios.de/projects/etc-proposals/"
SRC_URI="mirror://berlios/etc-proposals/${P}.tar.gz"

IUSE="gtk qt4"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="gtk? ( >=dev-python/pygtk-2.10 )
		qt4? ( >=dev-python/PyQt4-4.1.1
			>=kde-base/kdelibs-3.5 )"
RDEPEND="${DEPEND}"

src_install(){
	distutils_src_install
	dosbin "${D}"/usr/bin/etc-proposals
	rm -rf "${D}"/usr/{bin,share}
}

pkg_postinst() {
	elog "The configuration file has been installed to /etc/etc-proposals.conf"
	elog "If you are installing etc-proposals for the first time or updating"
	elog "from a version < 1.3 you should run the following command once:"
	elog "etc-proposals --init-db"
	ewarn "A full backup of /etc and other files managed by CONFIG_PROTECT"
	ewarn "is highly advised before testing this tool!"
}
