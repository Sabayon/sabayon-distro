# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="A Fast, Easy and Free BitTorrent client - daemon"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${PN/-daemon}/files/${P/-daemon}.tar.bz2"

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

S="${WORKDIR}/${P/-daemon}"

MY_PN=${PN/-daemon}

src_prepare() {
	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-cli \
		--enable-daemon \
		--disable-gtk
}

src_compile() {
	emake || die
}

src_install() {
	dobin daemon/transmission-daemon
	dobin daemon/transmission-remote
	
	doman daemon/transmission-daemon.1
	doman daemon/transmission-remote.1

	newinitd "${FILESDIR}"/${MY_PN}-daemon.initd.6 ${MY_PN}-daemon || die
	newconfd "${FILESDIR}"/${MY_PN}-daemon.confd.3 ${MY_PN}-daemon || die
}

pkg_postinst() {
	ewarn "If you use transmission-daemon, please, set 'rpc-username' and"
	ewarn "'rpc-password' (in plain text, transmission-daemon will hash it on"
	ewarn "start) in settings.json file located at /var/transmission/config or"
	ewarn "any other appropriate config directory."
	ewarn
	ewarn "You must change download location after you change a user daemon"
	ewarn "starts as, or it'll refuse to start, see bug #349867 for details."

}
