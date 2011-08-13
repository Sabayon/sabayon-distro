# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit autotools

MY_P="${P/_beta/b}"
MY_P="${MY_P/-daemon}"
MY_PN="${PN/-daemon}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - daemon"
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

	#mv third-party/miniupnp{,c} || die
	eautoreconf

	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	econf \
		$(use_enable nls) \
		--disable-cli \
		--enable-daemon \
		--disable-gtk \
		--enable-external-miniupnp \
		$(use_enable utp)
}

src_compile() {
	emake
}

src_install() {
	dobin daemon/transmission-daemon
	dobin daemon/transmission-remote

	doman daemon/transmission-daemon.1
	doman daemon/transmission-remote.1

	newinitd "${FILESDIR}"/${MY_PN}-daemon.initd.8 ${MY_PN}-daemon
	newconfd "${FILESDIR}"/${MY_PN}-daemon.confd.3 ${MY_PN}-daemon
}

pkg_postinst() {
	ewarn "If you use transmission-daemon, please, set 'rpc-username' and"
	ewarn "'rpc-password' (in plain text, transmission-daemon will hash it on"
	ewarn "start) in settings.json file located at /var/transmission/config or"
	ewarn "any other appropriate config directory."
	ewarn
	ewarn "You must change download location after you change a user daemon"
	ewarn "starts as, or it'll refuse to start, see bug #349867 for details."
	if use utp; then
		ewarn
		ewarn "Since uTP is enabled ${MY_PN} needs large kernel buffers for the UDP socket."
		ewarn "Please, add into /etc/sysctl.conf following lines:"
		ewarn " net.core.rmem_max = 4194304"
		ewarn " net.core.wmem_max = 1048576"
		ewarn "and run sysctl -p"
	fi
}
