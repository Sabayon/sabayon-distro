# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libtar/libtar-1.2.11-r1.ebuild,v 1.2 2006/12/30 20:10:40 vapier Exp $

inherit eutils

DESCRIPTION="C library for manipulating POSIX tar files"
HOMEPAGE="http://www.feep.net/libtar/"
SRC_URI="ftp://ftp.feep.net/pub/software/libtar/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="sys-libs/zlib"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-memleak.patch
	sed -i '/INSTALL_PROGRAM/s: -s$::' */Makefile.in
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog README TODO
}
