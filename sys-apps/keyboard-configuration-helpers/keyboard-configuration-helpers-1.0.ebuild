# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="SabayonLinux (Gentoo compatible) keymap configuration tool"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64 sparc"
IUSE=""

DEPEND="sys-apps/sed
	sys-apps/baselayout"


src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/* . -p

}

src_install () {

	cd ${WORKDIR}
	exeinto /sbin/
	doexe keyboard-setup

}
