# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
inherit base python

DESCRIPTION="Fedora legacy keyboard management tool."
HOMEPAGE="https://fedorahosted.org/system-config-keyboard/wiki"
SRC_URI="https://fedorahosted.org/released/system-config-keyboard/${P}.tar.gz"

LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""
DEPEND=""
RDEPEND="app-admin/firstboot"

pkg_postrm() {
        python_mod_cleanup /usr/share/${PN}
}
