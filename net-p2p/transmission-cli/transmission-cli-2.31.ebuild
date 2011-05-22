# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

MY_P="${P/_beta/b}"
MY_P="${MY_P/-cli}"
MY_PN="${PN/-cli}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - command line (CLI) version"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="utp"

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

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	econf \
		$(use_enable utp) \
		--enable-cli \
		--disable-daemon \
		--disable-gtk \
		--disable-gconf2
}

src_compile() {
	emake
}

src_install() {
	dobin cli/transmission-cli
	doman cli/transmission-cli.1
}
