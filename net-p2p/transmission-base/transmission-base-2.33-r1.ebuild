# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils autotools

MY_P="${P/_beta/b}"
MY_P="${MY_P/-base}"
MY_PN="${PN/-base}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - base files"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="
	sys-libs/zlib
	>=dev-libs/libevent-2.0.10
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	net-libs/miniupnpc"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	nls? ( sys-devel/gettext
		>=dev-util/intltool-0.40 )
	dev-util/pkgconfig
	sys-apps/sed
	!<net-p2p/transmission-gtk+-${PV}
	!<net-p2p/transmission-qt-${PV}
	!<net-p2p/transmission-daemon-${PV}
	!<net-p2p/transmission-cli-${PV}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewgroup transmission
	enewuser transmission -1 -1 -1 transmission
}

src_prepare() {
	# https://trac.transmissionbt.com/ticket/4323
	epatch "${FILESDIR}/${MY_P}-0001-configure.ac.patch"
	epatch "${FILESDIR}/${MY_P}-0002-config.in-4-qt.pro.patch"
	epatch "${FILESDIR}/${MY_P}-0003-system-miniupnpc.patch"

	# Upstream is not interested in this: https://trac.transmissionbt.com/ticket/4324
	sed -e 's|noinst\(_PROGRAMS = $(TESTS)\)|check\1|' -i libtransmission/Makefile.am || die

	# mv third-party/miniupnp{,c} || die
	eautoreconf

	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	# let's disable them
	econf \
		$(use_enable nls) \
		--disable-cli \
		--disable-utp \
		--disable-daemon \
		--disable-gtk \
		--enable-external-miniupnp
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS NEWS qt/README.txt
	rm -f "${ED}"/usr/share/${MY_PN}/web/LICENSE

	keepdir /var/{transmission/{config,downloads},log/transmission}
	fowners -R transmission:transmission /var/{transmission/{,config,downloads},log/transmission}
}

pkg_postinst() {
	# Keep default permissions on default dirs
	einfo "Seting owners of /var/{transmission/{,config,downloads},log/transmission}"
	chown -R transmission:transmission /var/{transmission/{,config,downloads},log/transmission}
}
