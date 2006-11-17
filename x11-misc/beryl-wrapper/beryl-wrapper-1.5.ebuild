# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils versionator

DESCRIPTION="Beryl and Emerald loader"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE=""

DEPEND=">=x11-base/xorg-x11-7.1
	x11-misc/beryl-manager
	>=x11-wm/beryl-0.1.2"


RDEPEND=""

src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/beryl-wrapper . -p

}

src_install () {

	cd ${WORKDIR}
	exeinto /usr/bin/
	doexe beryl-wrapper

}
