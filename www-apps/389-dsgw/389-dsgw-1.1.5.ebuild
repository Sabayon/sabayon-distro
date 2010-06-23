# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit autotools eutils

DESCRIPTION="389 Directory Server Gateway Web Application"
HOMEPAGE="http://port389.org/"
SRC_URI="http://directory.fedoraproject.org/sources/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +adminserver"

DEPEND="adminserv? ( net-nds/389-admin )
	dev-libs/nspr
	dev-libs/nss
	dev-libs/cyrus-sasl
	dev-libs/mozldap
	dev-libs/icu
	dev-libs/389-adminutil"

RDEPEND="${DEPEND}
	dev-perl/perl-mozldap
	virtual/perl-CGI"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_with adminserver) \
		--with-fhs || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README
}
