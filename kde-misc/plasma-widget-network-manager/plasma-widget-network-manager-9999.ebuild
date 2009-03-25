# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
KDE_MINIMAL="4.2"
inherit kde4-base subversion

ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/playground/base/plasma/applets/networkmanager"
DESCRIPTION="KDE plasma applet for controlling network connections managed by NetworkManager."
HOMEPAGE="http://websvn.kde.org/trunk/playground/base/plasma/applets/networkmanager/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="
	>=net-misc/networkmanager-0.7.0
	>=kde-base/plasma-workspace-4.2.1 kde-base/solid[networkmanager]
	"
LDFLAGS=""

src_unpack() {
	kde4-base_src_unpack
	cd ${S}
	# Fix dbus policy
	sed -i 's/at_console=".*"/group="plugdev"/' NetworkManager-kde4.conf
}

src_install() {

	kde4-base_src_install
	dodir /etc/dbus-1/system.d
	cd ${S}
	insinto /etc/dbus-1/system.d
	doins NetworkManager-kde4.conf

}
