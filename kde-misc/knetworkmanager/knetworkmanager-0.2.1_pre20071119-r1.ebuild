# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/knetworkmanager/knetworkmanager-0.2.1_pre20071119.ebuild,v 1.1 2007/12/03 00:37:30 rbu Exp $

inherit kde eutils

MY_PV="0.2.1r738551"
MY_P=${PN}-${MY_PV}

SLOT="0"
DESCRIPTION="A KDE frontend for NetworkManager"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
#SRC_URI="ftp://ftp.kde.org/pub/kde/stable/apps/KDE3.x/network/${P}.tar.bz2"
SRC_URI="http://beta1.suse.com/private/hschaa/knetworkmanager/${MY_P}.tar.bz2"
KEYWORDS="~amd64 ~x86"

IUSE="cisco openvpn pptp dialup networksettings"

DEPEND="net-misc/networkmanager
	=kde-base/kdelibs-3.5*
	>=dev-libs/dbus-qt3-old-0.70
	sys-apps/hal
	net-wireless/wireless-tools
	>=dev-libs/libnl-1.0_pre6-r1
	!net-misc/knetworkmanager
	cisco?   ( <net-misc/networkmanager-vpnc-0.7.0 )
	openvpn? ( >=net-misc/networkmanager-openvpn-0.3.2 )
	pptp?    ( <net-misc/networkmanager-pptp-0.7.0 )
	networksettings? ( net-misc/networksettings )
	dialup? ( || ( kde-base/kppp kde-base/kdenetwork ) )"

S="${WORKDIR}/${MY_P}"

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
	cd "${S}"

	epatch "${FILESDIR}/${PN}-0.2-pam_console-fix.patch"
	epatch "${FILESDIR}/${PN}-0.2.1-fixbuild_u64-hschaa-01.patch"
	use networksettings && epatch "${FILESDIR}/${PN}-0.2.1-networksettings.patch"
}

src_compile() {
	set-kdedir
	export PREFIX="${KDEDIR}"
	local myconf="$(use_with cisco vpnc) \
		$(use_with openvpn) \
		$(use_with pptp) \
		$(use_with dialup) \
		--with-distro=gentoo --disable-rpath"
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
