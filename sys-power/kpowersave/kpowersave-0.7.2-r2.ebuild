# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/kpowersave/kpowersave-0.6.2.ebuild,v 1.5 2006/12/16 22:55:58 genstef Exp $

inherit kde autotools

DESCRIPTION="KDE front-end to powersave daemon"
HOMEPAGE="http://powersave.sf.net/"
SRC_URI="mirror://sourceforge/powersave/${P}.tar.bz2"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=sys-apps/hal-0.5.8.1
	x11-libs/libXScrnSaver
	x11-libs/libXext
	x11-libs/libXtst"
DEPEND="${RDEPEND}
        || ( >=dev-libs/dbus-qt3-old-0.70 <sys-apps/dbus-0.70 )
	"

set-kdedir

src_compile() {
	cd ${S}
	eautomake || die "automake failed"
	eautoreconf || die "autoreconf failed"
	kde_src_compile myconf || die "myconf failed"
	kde_src_compile configure || die "configure failed"
	make || die "make failed"
}

#src_install() {
#	addwrite /usr/lib/
#	addwrite /usr/share/doc
#	addwrite /usr/share/locale
#	addwrite /usr/share/apps/
#	cd ${S}
#	kde_src_install dodoc
#	make install || die "make install"
#}
