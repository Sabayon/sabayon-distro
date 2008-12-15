# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ddcxinfo-knoppix/ddcxinfo-knoppix-0.6.ebuild,v 1.8 2008/11/23 18:18:37 jer Exp $

inherit eutils

IUSE=""

DESCRIPTION="Program to automatically probe a monitor for information"
HOMEPAGE="http://www.knopper.net/"

MY_PV=${PV}-5
SRC_URI="http://debian-knoppix.alioth.debian.org/sources/${PN}_${MY_PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 -amd64"

RDEPEND=""
DEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}/${PN}-kernel-headers.patch"
}

src_compile() {
	emake || die
}

src_install() {
	exeinto /usr/sbin
	doexe ddcxinfo-knoppix ddcprobe
	dodoc debian/changelog debian/control debian/copyright README
	doman debian/ddcxinfo-knoppix.1
}
