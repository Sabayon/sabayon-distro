# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils versionator

DESCRIPTION="Desktop Acceleration Configuration Helpers - Supporting XGL/AIGLX with Beryl"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE=""

DEPEND=">=x11-base/xorg-x11-7.1
	>=x11-wm/compiz-0.5.0
	x11-apps/fusion-icon"


src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/*-setup . -p
	epatch "${FILESDIR}"/desktop-acceleration-setup-ati-compiz-patch.patch
}

src_install () {

	cd ${WORKDIR}
	exeinto /sbin/
	doexe *-setup

	insinto /etc/
	doins ${FILESDIR}/${PV}/desktop-acceleration-helpers.conf

}
