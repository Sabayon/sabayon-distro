# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils eutils

DESCRIPTION="Nova's GUI to Entropy Package Manager"
HOMEPAGE="http://nova.prod.uci.cu"
SRC_URI="http://distfiles.sabayonlinux.org/app-admin/${P}.tar.bz2"
LICENSE="GPL-2"

SLOT="0"
IUSE=""
KEYWORDS="amd64 x86"

DEPEND="
	|| ( =dev-lang/python-2.5* =dev-lang/python-2.6* )
	>=x11-libs/gtk+-2.12.8
	>=x11-libs/gksu-2.0.0
	>=dev-python/pygtk-2.12.0
	>=sys-apps/entropy-0.50.0"

RDEPEND="${DEPEND}"

# Additional docs not covered by distutils
#DOCS="AUTHORS NEWS"

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_install() {
	distutils_src_install
}

pkg_postinst() {
    # Remove incompatible old configs.
    [[ -f /root/.summon/summon.conf ]] && rm /root/.summon/summon.conf
}
