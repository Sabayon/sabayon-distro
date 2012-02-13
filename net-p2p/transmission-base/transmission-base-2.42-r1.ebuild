# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit transmission-2.42

DESCRIPTION="A Fast, Easy and Free BitTorrent client - base files"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

DOCS="AUTHORS NEWS"

src_install() {
	default
	rm -f "${ED}"/usr/share/${MY_PN}/web/LICENSE

	keepdir /var/{transmission/{config,downloads},log/transmission}
	fowners -R transmission:transmission /var/{transmission/{,config,downloads},log/transmission}
}
