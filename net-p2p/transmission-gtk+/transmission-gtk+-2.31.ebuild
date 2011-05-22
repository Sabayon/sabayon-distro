# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils fdo-mime gnome2-utils

MY_P="${P/_beta/b}"
MY_P="${MY_P/-gtk+}"
MY_PN="${PN/-gtk+}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Gtk+ UI"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify libcanberra utp"

# >=dev-libs/glib-2.28 is required for updated mime support. This makes gconf
# unnecessary for handling magnet links
RDEPEND="
	~net-p2p/transmission-base-${PV}
	sys-libs/zlib
	>=dev-libs/libevent-2.0.10
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	>=dev-libs/glib-2.28:2
	>=x11-libs/gtk+-2.12:2
	>=dev-libs/dbus-glib-0.70
	libnotify? ( >=x11-libs/libnotify-0.4.3 )
	libcanberra? ( >=media-libs/libcanberra-0.10 )"
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
	# let's disable them
	econf \
		--disable-dependency-tracking \
		--disable-cli \
		--disable-daemon \
		--enable-gtk \
		$(use_enable utp) \
		$(use_enable libnotify) \
		$(use_enable libcanberra) \
		--disable-gconf2
}

src_compile() {
	emake
}

src_install() {
	# avoid file conflicts with transmission-base
	# this way gives the corrent layout of /usr/share/icon/... icon files
	emake DESTDIR="${T}" install

	cd "${T}"
	dobin usr/bin/transmission-gtk
	doman usr/share/man/man1/transmission-gtk.1
	doicon usr/share/pixmaps/transmission.png

	insinto /usr/share/applications
	doins usr/share/applications/transmission-gtk.desktop

	local mypath
	# locale
	for mypath in usr/share/locale/*/LC_MESSAGES/transmission-gtk.mo; do
		if [ -f "$mypath" ]; then
			insinto "${mypath%/*}"
			doins "$mypath"
		fi
	done

	# and finally icons directory
	for mypath in usr/share/icons/hicolor/*/apps/transmission.{png,svg}; do
		if [ -f "$mypath" ]; then
			insinto "${mypath%/*}"
			doins "$mypath"
		fi
	done
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
