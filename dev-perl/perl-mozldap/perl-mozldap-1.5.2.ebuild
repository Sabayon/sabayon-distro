# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit perl-module

DESCRIPTION="Mozilla PerLDAP"
HOMEPAGE="http://www.mozilla.org/directory/perldap.html"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/directory/perldap/releases/${PV}/src/${P}.tar.gz"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-libs/nspr-4.0.1
	>=dev-libs/nss-3.11.6
	>=dev-libs/mozldap-6.0.1"

RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}"/"gentoo.patch" )

SRC_TEST="do parallel"

src_prepare () {
	mv Makefile.PL.rpm Makefile.PL || die
	perl-module_src_prepare
}

