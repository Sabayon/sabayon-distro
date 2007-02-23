# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/libvirt/libvirt-0.1.7.ebuild,v 1.1 2006/10/10 22:05:41 agriffis Exp $

DESCRIPTION="C toolkit to manipulate virtual machines"
HOMEPAGE="http://www.libvirt.org/"
SRC_URI="ftp://libvirt.org/libvirt/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-libs/readline
	sys-libs/ncurses
	dev-libs/libxml2
	app-emulation/xen-tools
	dev-lang/python"

src_install() {
	make DESTDIR=${D} install || die
	mv ${D}/usr/share/doc/{${PN}-python*,${P}/python}
}
