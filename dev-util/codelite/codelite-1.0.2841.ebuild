# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="CodeLite is a powerful open-source, cross platform IDE for the C/C++ programming languages"
HOMEPAGE="http://codelite.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug gdb"

DEPEND=">=x11-libs/wxGTK-2.8.4
    gdb? ( sys-devel/gdb )"

src_compile() {
    econf $(use_enable debug)
    emake || die "emake failed"
}

src_install() {
    emake DESTDIR="${D}" install || die "install failed"

    dodoc FAQ NEWS README || die
}

