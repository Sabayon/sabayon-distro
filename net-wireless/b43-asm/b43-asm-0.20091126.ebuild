# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Assembler for Broadcom BCM43xx firmware"
HOMEPAGE="http://git.bu3sch.de/git/b43-tools.git"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"

EAPI="2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPEND=""
S="${WORKDIR}/assembler"

src_install() {
	dodir /usr/bin
	emake PREFIX="${D}"/usr install || die "emake failed"
}
