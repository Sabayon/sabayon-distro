# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/beryl-plugins/beryl-plugins-0.1.2.ebuild,v 1.1 2006/11/15 04:03:06 tsunam Exp $

inherit flag-o-matic

DESCRIPTION="Beryl Window Decorator Plugins"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://distfiles.gentoo-xeffects.org/beryl-releases/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="dbus"

DEPEND="~x11-wm/beryl-core-${PV}
	>=gnome-base/librsvg-2.14.0"

PDEPEND="dbus? ( ~x11-plugins/beryl-dbus-${PV} )"

src_compile() {
	# filter ldflags to follow upstream
	filter-ldflags -znow -z,now -Wl,-znow -Wl,-z,now

	econf || die "econf failed"
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
