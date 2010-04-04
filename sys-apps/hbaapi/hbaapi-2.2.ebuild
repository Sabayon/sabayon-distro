# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hbaapi/hbaapi-2.2.ebuild,v 1.3 2009/02/09 00:35:36 vapier Exp $

inherit eutils

MY_PN="${PN}_src"
MY_P="${MY_PN}_${PV}"
DESCRIPTION="The Host Bus Adapter API for managing Fibre Channel Host Bus Adapters"
HOMEPAGE="http://hbaapi.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tgz
	mirror://gentoo/${P}.Makefile.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc ~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/${P}.Makefile "${S}"/Makefile

	epatch "${FILESDIR}"/${P}-fix-implicit-conversion-to-pointer.patch

}

src_compile() {
	# not parallel safe!
	emake -j1 all || die
}

src_install() {
	into /usr
	dolib.so libHBAAPI.so || die
	dosbin hbaapitest || die
	insinto /etc
	doins "${FILESDIR}"/hba.conf
	dodoc readme.txt
}
