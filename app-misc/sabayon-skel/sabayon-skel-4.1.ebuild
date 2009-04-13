# Copyright 2004-2008 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-${PV}.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="
	=x11-themes/sabayon-artwork-4*
	!<=app-misc/sabayonlinux-skel-3.5-r6
	"


src_install () {

	cd ${WORKDIR}
	dodir /etc
	cp ${WORKDIR}/skel ${D}/etc -Ra
	chown root:root ${D}/etc/skel -R

}
