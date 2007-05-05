# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/libvirt/libvirt-0.1.7.ebuild,v 1.1 2006/10/10 22:05:41 agriffis Exp $

inherit eutils

DESCRIPTION="C toolkit to manipulate virtual machines"
HOMEPAGE="http://www.libvirt.org/"
SRC_URI="ftp://libvirt.org/libvirt/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="xen"

DEPEND="sys-libs/readline
	sys-libs/ncurses
	dev-libs/libxml2
	xen? ( >=app-emulation/xen-tools-3.0.4_p1 )
	dev-lang/python"

src_unpack() {
	unpack ${A}
}

src_compile() {
	cd ${S}
	
	EOPTS=""
	if ! use xen; then
		EOPTS="${EOPTS} --without-xen"
	fi

	econf ${EOPTS} || die "econf failed"

	if ! use xen; then
		epatch ${FILESDIR}/${P}-disable-xen.patch
	fi

	emake || die "make failed"

}

src_install() {
	make DESTDIR=${D} install || die
	mv ${D}/usr/share/doc/{${PN}-python*,${P}/python}
}
