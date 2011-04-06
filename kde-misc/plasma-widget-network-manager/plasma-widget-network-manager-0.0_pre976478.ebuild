# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
KDE_MINIMAL="4.2"
inherit kde4-base

SVN_REV="976478"
DESCRIPTION="KDE plasma applet for controlling network connections managed by NetworkManager."
HOMEPAGE="http://websvn.kde.org/trunk/playground/base/plasma/applets/networkmanager/"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/p/plasma-widget-network-manager/plasma-widget-network-manager_0.0+svn${SVN_REV}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="
	>=net-misc/networkmanager-0.7.0
	>=kde-base/plasma-workspace-4.2.1 kde-base/solid[networkmanager]
	"

S="${WORKDIR}/plasma-widget-network-manager-0.0+svn${SVN_REV}"
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
