# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A Python library designed to easily build user interfaces with embedded multimedia."
HOMEPAGE="http://elisa.fluendo.com"
SRC_URI="http://elisa.fluendo.com/static/download/pigment/${P}.tar.gz"

LICENSE="GPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
        emake DESTDIR="${D}" install || die "emake install failed"
}
