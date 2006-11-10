# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/ddccontrol-db/ddccontrol-db-20060730.ebuild,v 1.1 2006/10/01 20:12:48 robbat2 Exp $

DESCRIPTION="DDCControl monitor database"
HOMEPAGE="http://ddccontrol.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN/-db}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="${DEPEND}"

src_compile() {
	econf `enable_with nls` || die "econf failed"
	# Touch db/options.xml.h, so it is not rebuilt
	touch db/options.xml.h
	emake # doesn't really build anything, but there for safety
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
