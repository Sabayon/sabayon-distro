# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit transmission-2.92

DESCRIPTION="A Fast, Easy and Free BitTorrent client - base files"
KEYWORDS="~amd64 ~x86"
IUSE="lightweight xfs"

DEPEND="xfs? ( sys-fs/xfsprogs )"

DOCS="AUTHORS NEWS"

src_install() {
	default
	rm "${ED}"/usr/share/${MY_PN}/web/LICENSE || die
	dolib.a "${S}/libtransmission/libtransmission.a"
}
