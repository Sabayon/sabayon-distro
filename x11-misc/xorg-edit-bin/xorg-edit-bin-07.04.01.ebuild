# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

DESCRIPTION="GUI to edit XServer-file xorg.conf easily"
HOMEPAGE="http://www.cyskat.de/dee/progxorg.htm"
SRC_URI="http://umn.dl.sourceforge.net/sourceforge/xorg-edit/xorg-edit_07.01.04_bin.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND=">=x11-libs/wxGTK-2.6"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
}

src_compile() {
	einfo "This is a premade binary, no compilation necessary."
}

src_install() {
	dobin xorg-edit
	dodoc CHANGELOG README
	dodoc options/devices/*
}
