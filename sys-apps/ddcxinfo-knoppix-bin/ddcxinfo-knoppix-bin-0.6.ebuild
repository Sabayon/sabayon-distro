# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib

IUSE=""

DESCRIPTION="Program to automatically probe a monitor for information"
HOMEPAGE="http://www.knopper.net"

SRC_URI="mirror://sabayon/sys-apps/${PN}-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
DEPEND=""

src_unpack() {
	has_multilib_profile || die
	unpack ${A}
}

src_install() {

	cd ${WORKDIR}
	exeinto /usr/sbin
	doexe ddcxinfo-knoppix
	dodoc debian/changelog debian/control debian/copyright debian/README
	doman debian/ddcxinfo-knoppix.1
}
