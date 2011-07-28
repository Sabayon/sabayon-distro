# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit autotools

MY_P="${P/_beta/b}"
MY_P="${MY_P/-cli}"
MY_PN="${PN/-cli}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - command line (CLI) version"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls utp"

RDEPEND="
	~net-p2p/transmission-base-${PV}
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
	sys-apps/sed"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# https://trac.transmissionbt.com/ticket/4323
	epatch "${FILESDIR}/${MY_P}-0001-configure.ac.patch"
	epatch "${FILESDIR}/${MY_P}-0002-config.in-4-qt.pro.patch"
	epatch "${FILESDIR}/${MY_P}-0003-system-miniupnpc.patch"

	# Upstream is not interested in this: https://trac.transmissionbt.com/ticket/4324
	sed -e 's|noinst\(_PROGRAMS = $(TESTS)\)|check\1|' -i libtransmission/Makefile.am || die

	mv third-party/miniupnp{,c} || die
	eautoreconf

	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	econf \
		$(use_enable nls) \
		$(use_enable utp) \
		--enable-cli \
		--disable-daemon \
		--disable-gtk \
		--enable-external-miniupnp
}

src_compile() {
	emake
}

src_install() {
	dobin cli/transmission-cli
	doman cli/transmission-cli.1
}

pkg_postinst() {
	if use utp; then
		ewarn
		ewarn "Since uTP is enabled ${PN} needs large kernel buffers for the UDP socket."
		ewarn "Please, add into /etc/sysctl.conf following lines:"
		ewarn " net.core.rmem_max = 4194304"
		ewarn " net.core.wmem_max = 1048576"
		ewarn "and run sysctl -p"
	fi
}
