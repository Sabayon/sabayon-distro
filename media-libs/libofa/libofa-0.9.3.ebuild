# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="MusicDNS audio fingerprinting client library"
HOMEPAGE="http://www.musicdns.org/"
SRC_URI="http://www.musicdns.org/themes/musicdns_org/downloads/${P}.tar.gz"

LICENSE="|| ( GPL-2 APL )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

RDEPEND="dev-libs/expat
	net-misc/curl
	>=sci-libs/fftw-3"

DEPEND="${RDEPEND}"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/libofa-gcc-4.patch"
}

src_install() {
	make DESTDIR=${D} install || die "install failed"
	dodoc AUTHORS README COPYING

	if use examples; then
		docinto examples
		dodoc examples/*
	fi
}
