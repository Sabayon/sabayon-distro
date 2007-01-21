# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools

DESCRIPTION="Doc files stripped from SabayonLinux DVD/CD"
HOMEPAGE="http://sabayonlinux.org"
SRC_URI="http://sabayonlinux.org/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""

src_unpack() {
	einfo "This may take awhile"
}

src_compile() {
	einfo "Nothing to compile, just moving packages"
}

src_install() {
	einfo "Moving files .... may take awhile again"
	doinsinto /usr/share/man
	doins ${S}/* /usr/share/man
	einfo "Done installing man and doc pages"
}