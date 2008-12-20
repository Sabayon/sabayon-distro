# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/ximian-artwork/ximian-artwork-0.2.32.1.ebuild,v 1.3 2005/09/07 13:42:37 gustavoz Exp $

inherit eutils versionator

DESCRIPTION="SabayonLinux (Gentoo compatible) Locale configuration tool"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64 sparc"
IUSE=""

RDEPEND="sys-apps/sed
	sys-apps/baselayout"

DEPEND="${RDEPEND}"

src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/* . -p

}

src_install () {

	cd ${WORKDIR}
	exeinto /sbin/
	doexe language-setup

}
