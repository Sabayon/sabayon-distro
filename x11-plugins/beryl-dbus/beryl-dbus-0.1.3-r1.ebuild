# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/beryl-dbus/beryl-dbus-0.1.2.ebuild,v 1.1 2006/11/15 04:01:30 tsunam Exp $

inherit flag-o-matic

DESCRIPTION="Beryl Window Decorator Dbus Plugin"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://distfiles.gentoo-xeffects.org/beryl-releases/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"

DEPEND="~x11-plugins/beryl-plugins-${PV}
	sys-apps/dbus"

MAKEOPTS="${MAKEOPTS} -j1"

src_compile() {
	filter-ldflags -znow -z,now -Wl,-znow -Wl,-z,now

	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
