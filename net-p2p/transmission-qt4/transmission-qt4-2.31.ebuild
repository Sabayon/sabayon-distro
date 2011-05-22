# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils fdo-mime qt4-r2

MY_P="${P/_beta/b}"
MY_P="${MY_P/-qt4}"
MY_PN="${PN/-qt4}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Qt4 UI"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="kde utp"

# >=dev-libs/glib-2.28 is required for updated mime support. This makes gconf
# unnecessary for handling magnet links
RDEPEND="
	~net-p2p/transmission-base-${PV}
	sys-libs/zlib
	>=dev-libs/libevent-2.0.10
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	x11-libs/qt-gui:4[dbus]"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i -e 's:-ggdb3::g' configure || die
	# qtr / Qt Client fails to build when libutp is not available
	# https://trac.transmissionbt.com/ticket/4270
	# patch source: http://bugs.gentoo.org/show_bug.cgi?id=368187
	epatch "${FILESDIR}"/${MY_PN}_qt_utp.patch
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
		$(use_enable utp) \
		--disable-cli \
		--disable-daemon \
		--disable-gtk \
		--disable-gconf2

	cd qt && eqmake4 qtr.pro
}

src_compile() {
	emake
	cd qt && emake
}

src_install() {
	cd qt
	dodoc README.txt
	insinto /usr/share/applications/
	doins transmission-qt.desktop
	mv icons/transmission{,-qt}.png
	doicon icons/transmission-qt.png
	dobin transmission-qt
	doman transmission-qt.1
	if use kde; then
		insinto /usr/share/kde4/services/
		doins transmission-magnet.protocol
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
