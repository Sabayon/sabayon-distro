# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-mobilephone/x70talk/x70talk-0.1.4-r1.ebuild,v 1.4 2006/02/25 15:41:43 mrness Exp $

inherit eutils

DESCRIPTION="Communicate and sync with Panasonic X70 mobile phone"
HOMEPAGE="http://x70talk.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="ppc x86"
IUSE=""

DEPEND="net-wireless/bluez"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}/${PN}-correct-month.diff"
}

src_install() {
	dobin x70talk
	dodoc ChangeLog README TODO
}
