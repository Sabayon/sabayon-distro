# Copyright 2004-2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $


MY_P=${P/_/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Zinc stands for Zinc Is Not Cur(fl|ph)oo. Zinc is a Yahoo! chat client for GNU/Linux, FreeBSD, and Mac OS X"
HOMEPAGE="http://larvalstage.com/zinc/"
SRC_URI="http://larvalstage.com/zinc/files/${MY_P}.tar.bz2"
IUSE=""
SLOT="0"
LICENSE="|| ( GPL-2 AFL-2.0 )"
KEYWORDS="~x86 ~amd64"
DEPEND="dev-perl/Curses
        >=dev-lang/python-2.3.5-r2"

src_install() {
	# we are going to ignore the install.sh as it causes too much trouble and do it manually ourselves
	insinto /usr/lib/zinc
	doins src/*
	exeinto /usr/lib/zinc
	doexe src/zinc
	dodir /usr/bin
	dosym /usr/lib/zinc/zinc /usr/bin/zinc-chat
	docinto scripts
	dodoc scripts/*
	dodoc README
}

pkg_postinst() {
	ebeep
	ewarn "Due to zinc also being an emulator, zinc has been symlinked to /usr/bin/zinc-chat"
}

pkg_postrm() {
	python_mod_cleanup
}