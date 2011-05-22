# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="A BitTorrent client (meta package)"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI=""

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk kde libnotify libcanberra qt4 utp"

RDEPEND="~net-p2p/transmission-base-${PV}
	gtk? (
		~net-p2p/transmission-gtk+-${PV}
		~net-p2p/transmission-gtk+-${PV}[libnotify=]
		~net-p2p/transmission-gtk+-${PV}[libcanberra=]
		~net-p2p/transmission-gtk+-${PV}[utp=]
	)"
DEPEND="${RDEPEND}"
