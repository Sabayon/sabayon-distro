# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlitebrowser/sqlitebrowser-1.3.ebuild,v 1.5 2008/07/27 20:16:22 carlo Exp $

EAPI=1

inherit eutils qt3

DESCRIPTION="SQLite Database Browser"
HOMEPAGE="http://sqlitebrowser.sourceforge.net/"
SRC_URI="mirror://sourceforge/sqlitebrowser/${P}-src.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="=dev-db/sqlite-3*
	x11-libs/qt:3"

S="${WORKDIR}/${PN}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -r sqlite_source

	sed -i 's/\r/\n/g' *.{cpp,h}

	# I hate qt designer!
	has_version "=x11-libs/qt-3.3*" && sed -i '1s/UI version="3.2"/UI version="3.3"/'

	epatch "${FILESDIR}"/${P}-externalsqlite.patch
}

src_compile() {
	eqmake3
	emake || die "emake failed"
}

src_install() {
	dobin sqlitebrowser || die "installing failed"
}
