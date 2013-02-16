# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils transmission-2.76

DESCRIPTION="A Fast, Easy and Free BitTorrent client - command line (CLI) version"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	epatch "${FILESDIR}/${P}-segv.patch"
	transmission-2.76_src_prepare
}

src_install() {
	dobin cli/transmission-cli
	doman cli/transmission-cli.1
}
