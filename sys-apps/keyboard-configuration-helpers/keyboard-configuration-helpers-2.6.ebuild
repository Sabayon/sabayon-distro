# Copyright 2011 Fabio Erculiani
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Sabayon Keyboard configuration wrapper"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64 sparc"
IUSE=""

RDEPEND=""
DEPEND=""

src_install () {
	dodir /sbin
	exeinto /sbin
	doexe "${FILESDIR}/${PV}/keyboard-setup-2"
	dosym "keyboard-setup-2" /sbin/keyboard-setup
}
