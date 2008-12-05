# Copyright 2004-2008 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayonlinux.org/"
OLD_PN="sabayonlinux-skel"
OLD_PVR="3.50-r6"
SRC_URI="http://www.sabayonlinux.org/distfiles/app-misc/${OLD_PN}/${OLD_PN}-${OLD_PVR}.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="
	<x11-themes/sabayon-artwork-4.1
	!app-misc/sabayonlinux-skel
	"


src_install () {

	cd ${WORKDIR}
	dodir /etc
	cp ${WORKDIR}/skel ${D}/etc -Ra
	chown root:root ${D}/etc/skel -R

}
