# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic

DESCRIPTION="Con Kolivas' Benchmarking Suite -- Successor to Contest"
HOMEPAGE="http://members.optusnet.com.au/ckolivas/interbench/"
SRC_URI="mirror://kernel/linux/kernel/people/ck/apps/interbench/${PF}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e 's/CFLAGS/#CFLAGS/' \
		-e 's/CC/#CC/' Makefile || die "Can't sed Makefile!"
}

src_compile() {
	make CC="$(tc-getCC)" CFLAGS="${CFLAGS}" || die "Make Error!"
}

src_install() {
	dobin interbench
	dodoc readme*
	doman interbench.8
}

pkg_postinst() {
	einfo "${PN} has been installed to /usr/bin."
	einfo "For best and consistent results, it is recommended to"
	einfo "boot to init level 1 or use telinit 1."
	einfo "See documentation or ${HOMEPAGE} for more info."
}
