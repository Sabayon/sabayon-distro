# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Dynamic Kernel Module Support"
SRC_URI="http://linux.dell.com/dkms/permalink/${P}.tar.gz"
HOMEPAGE="http://linux.dell.com/dkms"
LICENSE="GPL-2"
DEPEND=""
KEYWORDS="~x86 ~amd64"
SLOT="0"

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
