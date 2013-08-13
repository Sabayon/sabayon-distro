# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
TRANSMISSION_ECLASS_VERSION_OK=2.80
inherit eutils transmission-2.80

DESCRIPTION="A Fast, Easy and Free BitTorrent client - command line (CLI) version"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	dobin cli/transmission-cli
	doman cli/transmission-cli.1
}
