# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils
MY_P="FrostWire"

DESCRIPTION="FrostWire is a high quality, FREE peer-to-peer application."
HOMEPAGE="http://www.frostwire.com"
SRC_URI="http://mirror1.peercommons.net/frostwire/${PV}/${MY_P}-${PV}-2.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~x86"
SLOT="0"
DEPEND="app-arch/gzip"

RDEPEND=">=virtual/jre-1.4.2
	>=virtual/jdk-1.4.2"

S="${WORKDIR}"

src_install() {

	insinto /usr/lib
	doins -r ${S}/${MY_P}-${PV}/usr/lib/*

	insinto /usr/share
	doins -r ${S}/${MY_P}-${PV}/usr/share/*

	exeinto /usr/bin
	doexe ${S}/${MY_P}-${PV}/usr/bin/*

}
