# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Sabayon live tool for X.Org video driver configuration"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE=""

RDEPEND=">=app-misc/sabayonlive-tools-1.6.0"
DEPEND=""

src_unpack () {
        cd "${WORKDIR}"
        cp "${FILESDIR}"/gpu-configuration . -p
}

src_install () {
	cd "${WORKDIR}"
	exeinto /sbin/
	doexe gpu-configuration
}
