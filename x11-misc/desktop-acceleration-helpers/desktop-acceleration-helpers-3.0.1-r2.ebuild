# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils versionator

DESCRIPTION="Desktop Acceleration Configuration Helpers - Supporting AIGLX and Compiz"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE=""

src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/*-setup . -p
}

src_install () {

	cd ${WORKDIR}
	exeinto /sbin/
	doexe *-setup

	insinto /etc/
	doins ${FILESDIR}/${PV}/desktop-acceleration-helpers.conf

}
