# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/ximian-artwork/ximian-artwork-0.2.32.1.ebuild,v 1.3 2005/09/07 13:42:37 gustavoz Exp $

inherit eutils versionator

DESCRIPTION="Fake library to LD_PRELOAD to accelerate AIGLX under heavy load"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE=""

DEPEND=">=x11-base/xorg-x11-7.1"


RDEPEND=""

S="${WORKDIR}/${PN}"

src_compile () {

	cd ${S}
	cp ${FILESDIR}/sched.c .
	cp ${FILESDIR}/09aiglx .
	gcc -rdynamic -shared -fPIC -o sched.so sched.c

}

src_install () {

	cd ${S}
	insinto /usr/lib/
	doins *.so

	cd ${S}
	insinto /etc/env.d/
	doins 09aiglx

}
