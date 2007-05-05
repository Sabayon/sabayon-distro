# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/raidutils/raidutils-0.0.6-r1.ebuild,v 1.1 2007/02/28 22:59:11 xmerlin Exp $

inherit eutils

DESCRIPTION="Utilities to manage i2o/dtp RAID controllers."
SRC_URI="http://i2o.shadowconnect.com/raidutils/${P}.tar.bz2"
HOMEPAGE="http://i2o.shadowconnect.com/"

KEYWORDS="x86"
IUSE=""

SLOT="0"
LICENSE="Adaptec"

DEPEND=">=sys-kernel/linux-headers-2.6"
RDEPEND=""

src_unpack () {
	unpack ${A}
	cd ${S}
	#epatch ${FILESDIR}/raidutils-0.0.5-i2octl-fixpath.patch
	#epatch ${FILESDIR}/raidutils-0.0.6-gcc41x-compilefix.patch
	epatch ${FILESDIR}/${P}-misc-fixes.patch
	epatch ${FILESDIR}/${P}-remove-i2o-dev.patch
}

src_compile() {
	econf || die
	emake -j1 || die
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc NEWS INSTALL AUTHORS COPYING ChangeLog
}
