# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit transmission-${PVR}

DESCRIPTION="A Fast, Easy and Free BitTorrent client - command line (CLI) version"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	dobin cli/transmission-cli
	doman cli/transmission-cli.1
}
