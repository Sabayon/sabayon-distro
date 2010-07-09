# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

DESCRIPTION="A fairly simple module, it provide only raw yEnc
encoding/decoding with builitin crc32 calculation.."
HOMEPAGE="http://sourceforge.net/projects/sabnzbd"
SRC_URI="http://sabnzbd.sourceforge.net/yenc-0.3.tar.gz"
S=${WORKDIR}/yenc-${PV}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-lang/python-2.1"

src_unpack() {
	unpack ${A} || die
	cd ${S}
}

src_install() {
	distutils_src_install
	insinto /usr/share/doc/${P}
	doins -r yenc/doc
	insinto /usr/share/${PN}
	doins -r yenc/test
}

src_test() {
	cd yenc/test
	python test.py || die "Test failed."
}
