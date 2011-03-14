# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="A Fast, Easy and Free BitTorrent client - command line (CLI) version"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${PN/-cli}/files/${P/-cli}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	~net-p2p/transmission-base-${PV}
	sys-libs/zlib
	>=dev-libs/libevent-2.0.10
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed"

S="${WORKDIR}/${P/-cli}"

src_prepare() {
	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-cli \
		--disable-daemon \
		--disable-gtk
}

src_compile() {
	emake || die
}

src_install() {
	dobin cli/transmission-cli
	doman cli/transmission-cli.1
}
