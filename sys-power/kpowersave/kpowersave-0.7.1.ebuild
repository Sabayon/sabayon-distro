# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/kpowersave/kpowersave-0.6.2.ebuild,v 1.5 2006/12/16 22:55:58 genstef Exp $

inherit kde

DESCRIPTION="KDE front-end to powersave daemon"
HOMEPAGE="http://powersave.sf.net/"
SRC_URI="mirror://sourceforge/powersave/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=sys-apps/hal-0.5.8.1
	<sys-apps/dbus-0.63
	x11-libs/libXScrnSaver
	x11-libs/libXext
	x11-libs/libXtst"
DEPEND="${RDEPEND}
	kde-base/unsermake"

# when SL will use dbus-1.0
# use: dev-libs/dbus-qt3-old-0.70

set-kdedir

src_compile() {
	# workarounding unsermake problems
	cd ${S}
	kde_src_compile myconf || die "myconf failed"
	kde_src_compile configure || die "configure failed"
	make || die "make failed"
}

src_install() {
	addwrite /usr/lib/
	cd ${S}
	kde_src_install dodoc
	make install || die "make install"
}
