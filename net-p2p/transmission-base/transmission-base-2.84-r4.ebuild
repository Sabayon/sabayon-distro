# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit transmission-2.84

DESCRIPTION="A Fast, Easy and Free BitTorrent client - base files"
KEYWORDS="~amd64 ~x86"
IUSE="lightweight xfs"

DEPEND="xfs? ( sys-fs/xfsprogs )"

DOCS="AUTHORS NEWS"

TRANSMISSION_PATCHES=(
	"${FILESDIR}/2.84-miniupnp14.patch"
	"${FILESDIR}/2.84-libevent-2.1.5.patch"
	"${FILESDIR}/2.84-node_alloc-segfault.patch"
)

src_install() {
	default
	rm "${ED}"/usr/share/${MY_PN}/web/LICENSE || die

	keepdir /var/{lib/${MY_PN}/{config,downloads},log/${MY_PN}}
	fowners -R ${MY_PN}:${MY_PN} /var/{lib/${MY_PN}/{,config,downloads},log/${MY_PN}}
	dolib.a "${S}/libtransmission/libtransmission.a"
}
