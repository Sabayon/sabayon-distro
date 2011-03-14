# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/transmission/transmission-2.13.ebuild,v 1.3 2011/02/12 09:28:16 pva Exp $

EAPI=2
inherit eutils

DESCRIPTION="A Fast, Easy and Free BitTorrent client - base files"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${PN/-base}/files/${P/-base}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	sys-libs/zlib
	>=dev-libs/libevent-1.4.11
	<dev-libs/libevent-2
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed
	!<net-p2/transmission-gtk+-${PV}
	!<net-p2/transmission-qt-${PV}
	!<net-p2/transmission-daemon-${PV}
	!<net-p2/transmission-cli-${PV}"

pkg_setup() {
	enewgroup transmission
	enewuser transmission -1 -1 -1 transmission
}

S="${WORKDIR}/${P/-base}"

src_prepare() {
	# epatch "${FILESDIR}"/"${P/-base}"-libnotify-0.7.patch

	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	# let's disable them
	econf \
		--disable-dependency-tracking \
		--disable-cli \
		--disable-daemon \
		--disable-gtk
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS NEWS qt/README.txt
	rm -f "${D}"/usr/share/${PN}/web/LICENSE

	keepdir /var/{transmission/{config,downloads},log/transmission}
	fowners -R transmission:transmission /var/{transmission/{,config,downloads},log/transmission}
}

pkg_postinst() {
	# Keep default permissions on default dirs
	chown -R transmission:transmission /var/{transmission/{,config,downloads},log/transmission}
}
