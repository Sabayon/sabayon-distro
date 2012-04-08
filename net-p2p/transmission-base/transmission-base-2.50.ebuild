# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit transmission-2.50

DESCRIPTION="A Fast, Easy and Free BitTorrent client - base files"
KEYWORDS="~amd64 ~x86"
IUSE=""

DOCS="AUTHORS NEWS"

src_install() {
	default
	rm "${ED}"/usr/share/${MY_PN}/web/LICENSE || die

	keepdir /var/{${MY_PN}/{config,downloads},log/${MY_PN}}
	fowners -R ${MY_PN}:${MY_PN} /var/{${MY_PN}/{,config,downloads},log/${MY_PN}}
}
