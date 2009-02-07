# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-qt3-old/dbus-qt3-old-0.70.ebuild,v 1.15 2008/08/18 18:50:28 rbu Exp $

inherit qt3

DESCRIPTION="D-BUS Qt3 bindings backported from Qt4"
HOMEPAGE="http://freedesktop.org/wiki/Software/dbus"
SRC_URI="http://www.sabayonlinux.org/distfiles/dev-libs/${P}.tar.gz"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="debug"

RDEPEND=">=sys-apps/dbus-0.91"
DEPEND="${RDEPEND}
	=x11-libs/qt-3*"
S="${WORKDIR}/dbus-1-qt3-${PV}"

src_compile() {
	econf --with-qt3-moc=${QTDIR}/bin/moc \
		  $(use_enable debug qt-debug) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
