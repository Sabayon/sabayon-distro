# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
KDE_MINIMAL="4.2"
inherit kde4-base

SVN_REV="930811"
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
