# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyparted/pyparted-1.8.9.ebuild,v 1.2 2007/08/27 19:59:18 wolf31o2 Exp $

inherit flag-o-matic multilib

DESCRIPTION="Python bindings for parted"
HOMEPAGE="http://dcantrel.fedorapeople.org/pyparted/"
SRC_URI="http://dcantrel.fedorapeople.org/pyparted/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
DEPEND="sys-libs/ncurses"
IUSE=""

# Needed to build...
DEPEND=">=dev-lang/python-2.4
	>=sys-apps/parted-1.7.0"

RDEPEND="${DEPEND}"

src_compile() {
	einfo "Fixing libdir"
	sed -i "s/\$(shell rpm --eval \"%{_libdir}\")/usr\/$(get_libdir)/" Makefile || die "cannot fix libdir"
	useq debug && append-flags -O -ggdb -DDEBUG
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README ChangeLog
}
