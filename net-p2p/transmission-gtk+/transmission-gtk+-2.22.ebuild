# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils fdo-mime gnome2-utils

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Gtk+ UI"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${PN/-gtk+}/files/${P/-gtk+}.tar.bz2"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome gtk libnotify libcanberra"

RDEPEND="
	~net-p2p/transmission-base-${PV}
	sys-libs/zlib
	>=dev-libs/libevent-2.0.10
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	gtk? ( >=dev-libs/glib-2.15.5:2
		>=x11-libs/gtk+-2.12:2
		>=dev-libs/dbus-glib-0.70
		gnome? ( >=gnome-base/gconf-2.20.0 )
		libnotify? ( >=x11-libs/libnotify-0.4.3 )
		libcanberra? ( >=media-libs/libcanberra-0.10 ) )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed"

S="${WORKDIR}/${P/-gtk+}"

pkg_setup() {
	use gtk || \
		die "This requires gtk+ USE flag to build, but it is not set."
}

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
		$(use_enable gtk) \
		$(use gtk && use_enable libnotify) \
		$(use gtk && use_enable libcanberra) \
		$(use gtk && use_enable gnome gconf2)
}

src_compile() {
	emake || die
}

src_install() {
	# avoid file conflicts with transmission-base
	# this way gives the corrent layout of /usr/share/icon/... icon files
	emake DESTDIR="${T}" install || die

	cd "${T}"
	dobin usr/bin/transmission-gtk || die
	doman usr/share/man/man1/transmission-gtk.1 || die
	doicon usr/share/pixmaps/transmission.png || die
	
	insinto /usr/share/applications
	doins usr/share/applications/transmission-gtk.desktop || die
	
	local mypath
	# locale
	for mypath in usr/share/locale/*/LC_MESSAGES/transmission-gtk.mo; do
		if [ -f "$mypath" ]; then
			insinto "${mypath%/*}"
			doins "$mypath" || die "doins for locale failed"
		fi
	done
	
	# and finally icons directory
	for mypath in usr/share/icons/hicolor/*/apps/transmission.{png,svg}; do
		if [ -f "$mypath" ]; then
			insinto "${mypath%/*}"
			doins "$mypath" || die "doins for icons failed"
		fi
	done
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update

	if use gtk; then
		elog 'If you want magnet link support in gnome run this commands:'
		elog 'gconftool-2 -t string -s /desktop/gnome/url-handlers/magnet/command "/usr/bin/transmission-gtk %s"'
		elog 'gconftool-2 -s /desktop/gnome/url-handlers/magnet/needs_terminal false -t bool'
		elog 'gconftool-2 -t bool -s /desktop/gnome/url-handlers/magnet/enabled true'
	fi
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
