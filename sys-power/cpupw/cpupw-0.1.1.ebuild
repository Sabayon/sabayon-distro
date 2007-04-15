# Copyright 1999-2006 Gentoo Foundation
# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Small userspace utility that let manage the voltage of AMD Athlon64/Opteron and Centrino CPUs"
HOMEPAGE="http://www.tuxamito.com.es/cpupw"
SRC_URI="http://www.tuxamito.com.es/cpupw/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

src_compile() {
	cd ${S}/src
	emake || die "make failed"
	mv ${S}/src/cpupw.init ${S}/cpupw
}

src_install() {
	cd ${S}/src
	exeinto /usr/sbin
	doexe cpupw
	doinitd ${S}/cpupw
}
