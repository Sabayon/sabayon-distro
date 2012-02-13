# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit transmission-2.42

DESCRIPTION="A BitTorrent client (meta package)"
#HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI=""

#LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ayatana gtk kde nls qt4"

RDEPEND="
	gtk? (
		~net-p2p/transmission-gtk+-${PV}[ayatana=]
	)"
