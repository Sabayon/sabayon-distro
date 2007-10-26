# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde eutils

DESCRIPTION="A NetworkManager front-end for KDE"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
SRC_URI="http://www.sabayonlinux.org/distfiles/net-misc/${PN}/${PN}-${PV/.1_pre*/}_pre20070702.tar.bz2"
KEYWORDS="~x86 ~amd64"
RESTRICT="nomirror"
S=${WORKDIR}/${PN}
IUSE="cisco openvpn pptp dialup"

RDEPEND="
	>=kde-base/kdelibs-3.2
	>=dev-libs/dbus-qt3-old-0.70
	sys-apps/hal
	>=net-misc/networkmanager-0.6.3
        net-wireless/wireless-tools
        dev-libs/libnl
        cisco?   ( <net-misc/networkmanager-vpnc-0.7.0 )
        openvpn? ( <net-misc/networkmanager-openvpn-0.3.3 )
        pptp?    ( <net-misc/networkmanager-pptp-0.7.0 )
        dialup? ( || ( kde-base/kppp kde-base/kdenetwork ) )
	"
DEPEND="${RDEPEND}"

pkg_setup() {
        kde_pkg_setup

        if has_version "<sys-apps/dbus-0.9*" && ! built_with_use sys-apps/dbus qt3 ; then
                echo
                eerror "You must rebuild sys-apps/dbus with USE=\"qt3\" or use a newer version of dbus"
                die "sys-apps/dbus not built with qt3 bindings"
        fi
}

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
