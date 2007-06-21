# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/xdelta/xdelta-1.1.3-r2.ebuild,v 1.3 2007/04/23 16:51:41 gustavoz Exp $

inherit eutils toolchain-funcs

XD_REV="${PV/.}q"
DESCRIPTION="Computes changes between binary or text files and creates deltas"
HOMEPAGE="http://www.xdelta.org"
SRC_URI="http://www.sabayonlinux.org/distfiles/dev-util/xdelta/${PN}${XD_REV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ia64 ~ppc ~ppc64 sparc x86"
IUSE=""
RESTRICT="nomirror"
S=${WORKDIR}/${PN}${XD_REV}

DEPEND=">=sys-libs/zlib-1.1.4"

src_unpack() {
	unpack ${A}
}

src_compile() {
	emake || die
}

src_install() {
	cd ${S}
	exeinto /usr/bin
	doexe xdelta3
}
