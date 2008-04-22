# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/btg/btg-0.9.6-r1.ebuild,v 1.3 2008/02/06 14:16:09 angelos Exp $

EAPI="1"

inherit autotools eutils

DESCRIPTION="bittorrent client using rb_libtorrent"
HOMEPAGE="http://btg.berlios.de/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="debug doc event-callback gtk minimal ncurses session test webinterface"

RDEPEND=">=dev-libs/boost-1.34.1
	dev-libs/expat
	dev-libs/libgcrypt
	dev-libs/libgpg-error
	dev-libs/libtasn1
	dev-util/dialog
	net-libs/gnutls
	>=net-libs/rb_libtorrent-0.13_rc1
	gtk? ( dev-cpp/gtkmm:2.4
		x11-libs/pango
		dev-libs/libsigc++:2 )
	webinterface? ( =dev-lang/php-5* virtual/httpd-cgi )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.21
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch \
		"${FILESDIR}/${P}-as_needed.patch" \
		"${FILESDIR}/${P}-broken_bundled_plotmm_sigc.patch"
	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	econf \
		$(use_enable debug) \
		$(use_enable gtk gui) \
		$(use_enable ncurses cli) \
		$(use_enable event-callback) \
		$(use_enable session session-saving) \
		$(use_enable test unittest) \
		$(use_enable webinterface www) \
		$(use_enable !minimal command-list) \
		--disable-upnp \
		--disable-dependency-tracking \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog README TODO

	newinitd "${FILESDIR}/btgd-init" ${PN}
	newconfd "${FILESDIR}/btgd-confd" ${PN}

	use gtk && make_desktop_entry btgui "BTG GUI Client" btg "Network;P2P"
}

pkg_postinst() {
	enewgroup p2p
	enewuser p2p -1 -1 /home/p2p p2p

	echo
	elog "BTG needs a daemon.ini and client.ini, to create them run btg-config"
	elog "and put them in the home of the user running btg (/home/p2p/.btg by default)"
	echo
}
