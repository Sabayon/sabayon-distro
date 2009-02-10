# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
KDE_MINIMAL="4.2"
inherit kde4-base

DESCRIPTION="KDE plasma applet for controlling network connections managed by NetworkManager."
HOMEPAGE="http://websvn.kde.org/trunk/playground/base/plasma/applets/networkmanager/"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/p/plasmoid-network-manager/plasmoid-network-manager_0.0+svn923467.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

# DEPEND="!kde-misc/plasmoids
#		kde-base/libplasma"
DEPEND=">=net-misc/networkmanager-0.7.0"

S="${WORKDIR}/plasmoid-network-manager-0.0+svn923467"
LDFLAGS=""
