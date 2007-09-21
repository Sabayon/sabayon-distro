# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde eutils

DESCRIPTION="A NetworkManager front-end for KDE"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
SRC_URI="http://www.sabayonlinux.org/distfiles/net-misc/${PN}/${P}.tar.bz2"
KEYWORDS="~x86 ~amd64"
RESTRICT="nomirror"
S=${WORKDIR}/${PN}

RDEPEND="
	>=kde-base/kdelibs-3.2
	|| ( >=dev-libs/dbus-qt3-old-0.70
		( <sys-apps/dbus-0.70 ) )
	>=sys-apps/hal-0.5.9
	>=net-misc/networkmanager-0.6.3
	"
DEPEND="${RDEPEND}"

src_unpack() {
	kde_src_unpack
	cd ${S}
	epatch ${FILESDIR}/${PN}-linux-types.patch
}

src_compile() {
	export MAKEOPTS="-j1"
	kde_src_compile
}

src_install() {
	kde_src_install
}
