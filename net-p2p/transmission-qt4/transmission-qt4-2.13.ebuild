# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils fdo-mime qt4-r2

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Qt4 UI"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${PN/-qt4}/files/${P/-qt4}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="kde qt4"

RDEPEND="
	~net-p2p/transmission-base-${PV}
	sys-libs/zlib
	>=dev-libs/libevent-1.4.11
	<dev-libs/libevent-2
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	qt4? ( x11-libs/qt-gui:4[dbus] )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed"

S="${WORKDIR}/${P/-qt4}"

pkg_setup() {
	use qt4 || \
		die "This requires qt4 USE flag to build, but it is not set."
}

src_prepare() {
	epatch "${FILESDIR}"/${P/-qt4}-libnotify-0.7.patch

	sed -i -e 's:-ggdb3::g' configure || die
	# Magnet link support
	if use kde; then
		cat > qt/transmission-magnet.protocol <<-EOF
		[Protocol]
		exec=transmission-qt '%u'
		protocol=magnet
		Icon=transmission
		input=none
		output=none
		helper=true
		listing=
		reading=false
		writing=false
		makedir=false
		deleting=false
		EOF
	fi
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	# let's disable them
	econf \
		--disable-dependency-tracking \
		--disable-cli \
		--disable-daemon \
		--disable-gtk
	
	use qt4 && cd qt && eqmake4 qtr.pro
}

src_compile() {
	emake || die
	use qt4 && cd qt && { emake || die; }
}

src_install() {
	dodoc qt/README.txt

	if use qt4; then
		cd qt
		insinto /usr/share/applications/
		doins transmission-qt.desktop || die
		mv icons/transmission{,-qt}.png
		doicon icons/transmission-qt.png || die
		dobin transmission-qt || die
		doman transmission-qt.1 || die
		if use kde; then
			insinto /usr/share/kde4/services/
			doins transmission-magnet.protocol || die
		fi
	fi

}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
