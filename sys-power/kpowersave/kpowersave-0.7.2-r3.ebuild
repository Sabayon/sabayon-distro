# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-power/kpowersave/kpowersave-0.7.2.ebuild,v 1.3 2007/03/06 22:15:16 genstef Exp $

inherit kde

DESCRIPTION="KDE front-end to powersave daemon"
HOMEPAGE="http://powersave.sf.net/"
SRC_URI="mirror://sourceforge/powersave/${P}.tar.bz2
	mirror://gentoo/kde-admindir-3.5.5.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=sys-apps/hal-0.5.4
	dev-libs/dbus-qt3-old
	x11-libs/libXScrnSaver
	x11-libs/libXext
	x11-libs/libXtst
	>=sys-power/powersave-0.11.5"
DEPEND="${RDEPEND}"

set-kdedir

src_unpack() {
	unpack ${A}
	rm -rf "${S}/admin" "${S}/configure"
	ln -s "${WORKDIR}/admin" "${S}/admin"
}
