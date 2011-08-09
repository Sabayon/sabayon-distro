# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils toolchain-funcs git-2

DESCRIPTION="QC compiler for Xonotic"
HOMEPAGE="http://git.xonotic.org/?p=xonotic/fteqcc.git;a=summary"
EGIT_REPO_URI="git://git.xonotic.org/xonotic/fteqcc.git"
EGIT_BRANCH="xonotic-stable"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="test"

DEPEND=""
RDEPEND=""

src_prepare() {
	sed -i \
		-e '/^CC/d' \
		-e 's: -O3 : :g' \
		-e "/BASE_LDFLAGS=/s:-s:${LDFLAGS}:g" \
		Makefile || die
}

src_compile() {
	emake CC=$(tc-getCC) BASE_CFLAGS="${CFLAGS} -Wall"
}

src_install() {
	newbin fteqcc.bin ${PN}

	dodoc readme.txt
}
