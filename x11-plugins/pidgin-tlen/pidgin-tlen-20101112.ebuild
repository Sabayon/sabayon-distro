# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit multilib

DESCRIPTION="Pidgin plugin for adding Tlen.pl support"
HOMEPAGE="http://nic.com.pl/~alek/pidgin-tlen/"
SRC_URI="http://nic.com.pl/~alek/pidgin-tlen/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=net-im/pidgin-2.6.5"
RDEPEND="${DEPEND}"

src_compile() {
	emake || die "emake failed"
}

src_install() {
	exeinto "/usr/$(get_libdir)/purple-2"
	doexe libtlen.so || die "doexe failed"

	dodoc README || die "dodoc failed"

	local mydir
	for mydir in 16 22 48; do
		insinto "/usr/share/pixmaps/pidgin/protocols/${mydir}"
		newins tlen_${mydir}.png tlen.png \
			|| die "doins for ${mydir} failed"
	done
}
