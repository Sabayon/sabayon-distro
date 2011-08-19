# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: mail-client/davmail-3.8.5 $

EAPI=3
inherit eutils

MY_VER="1750"

DESCRIPTION="POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange Gateway"
HOMEPAGE="http://davmail.sourceforge.net/"
SRC_URI="x86? ( mirror://sourceforge/davmail/${P/$PN/$PN-linux-x86}-${MY_VER}.tgz )
	 amd64? ( mirror://sourceforge/davmail/${P/$PN/$PN-linux-x86_64}-${MY_VER}.tgz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND="virtual/jre:1.6"
RDEPEND="${DEPEND}"

use x86 && S="${P/$PN/$PN-linux-x86_64}-${MY_VER}"
use amd64 && S="${P/$PN/$PN-linux-x86_64}-${MY_VER}"

src_install() {
	cd "${S}"

	# Fix the script BASE=
	sed -i -e "s@BASE=.*@BASE=/opt/davmail@" davmail.sh

	dodir "/opt/$PN"
	cp -a * "${D}/opt/$PN"

	dodir "/opt/bin"
	dosym "/opt/$PN/davmail.sh" "/opt/bin/davmail.sh"

	domenu "${FILESDIR}"/davmail.desktop
	doicon "${FILESDIR}"/davmail.png

}
