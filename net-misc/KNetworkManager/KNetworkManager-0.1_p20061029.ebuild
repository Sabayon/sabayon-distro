# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="A NetworkManager front-end for KDE"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
SRC_URI="http://distfiles.evolution-mission.org/kde/${PN}-${PV##*_p}.tar.bz2"
KEYWORDS="~amd64 ~x86"

DEPEND="net-misc/NetworkManager
	>=kde-base/kdelibs-3.2
	sys-apps/dbus
	sys-apps/hal"

S="${WORKDIR}/${PN}-${PV##*_p}"

pkg_setup() {
	if ! built_with_use sys-apps/dbus qt3 ; then
		echo
		eerror "You must rebuild sys-apps/dbus with USE=\"qt3\""
		die "sys-apps/dbus not built with qt3 bindings"
	fi
}