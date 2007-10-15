# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/knetworkmanager/knetworkmanager-0.2.ebuild,v 1.3 2007/08/29 21:32:53 rbu Exp $

inherit kde eutils

DESCRIPTION="A KDE frontend for NetworkManager"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
SRC_URI="ftp://ftp.kde.org/pub/kde/stable/apps/KDE3.x/network/${P}.tar.bz2
	mirror://gentoo/kde-admindir-3.5.5.tar.bz2"
KEYWORDS="~amd64 ~x86"

IUSE="cisco openvpn pptp"

DEPEND="net-misc/networkmanager
	|| ( kde-base/kppp kde-base/kdenetwork )
	>=kde-base/kdelibs-3.2
	>=dev-libs/dbus-qt3-old-0.70
	sys-apps/hal
	net-wireless/wireless-tools
	dev-libs/libnl
	cisco?   ( <net-misc/networkmanager-vpnc-0.7.0 )
	openvpn? ( <net-misc/networkmanager-openvpn-0.3.3 )
	pptp?    ( <net-misc/networkmanager-pptp-0.7.0 )"

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
	ln -s "${WORKDIR}/admin" "${S}/admin"
	cd "${S}"

	epatch "${FILESDIR}/${P}-kppp.patch"
	epatch "${FILESDIR}/${P}-pam_console-fix.patch"
	epatch "${FILESDIR}/${P}-fix-desktop-icon.patch"
	epatch "${FILESDIR}/${P}-fixbuild_u64-hschaa-01.patch"
}

src_compile() {
	set-kdedir
	export PREFIX="${KDEDIR}"
	local myconf="$(use_with cisco vpnc) $(use_with openvpn) $(use_with pptp) --with-distro=gentoo --disable-rpath"
	kde_src_compile
}

src_install() {
	kde_src_install

	# kde.eclass sets sysconfdir too weird for us, delete conf from there and reinstall to /etc
	set-kdedir
	rm -rf "${D}/${KDEDIR}/etc"
	insinto /etc/dbus-1/system.d/
	doins knetworkmanager/knetworkmanager.conf
}
