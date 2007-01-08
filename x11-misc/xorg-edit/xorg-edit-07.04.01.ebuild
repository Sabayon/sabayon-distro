# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

DESCRIPTION="GUI to edit XServer-file xorg.conf easily"
HOMEPAGE="http://www.cyskat.de/dee/progxorg.htm"
SRC_URI="http://superb-east.dl.sourceforge.net/sourceforge/xorg-edit/xorg-edit_07.01.04_src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=x11-libs/wxGTK-2.6"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-makefile.patch"
}

src_compile() {
	cd sources
	emake CXX=$(tc-getCXX) || die "emake failed"
}

src_install() {
	dobin sources/xorg-edit
	dodoc changelog.txt readme.txt
}
