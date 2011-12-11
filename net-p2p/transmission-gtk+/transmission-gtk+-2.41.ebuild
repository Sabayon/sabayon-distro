# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils fdo-mime gnome2-utils autotools

MY_P="${P/_beta/b}"
MY_P="${MY_P/-gtk+}"
MY_PN="${PN/-gtk+}"

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Gtk+ UI"
HOMEPAGE="http://www.transmissionbt.com/"
SRC_URI="http://download.transmissionbt.com/${MY_PN}/files/${MY_P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="utp"

RDEPEND="
	~net-p2p/transmission-base-${PV}
	sys-libs/zlib
	>=dev-libs/libevent-2.0.10
	>=dev-libs/openssl-0.9.4
	|| ( >=net-misc/curl-7.16.3[ssl]
		>=net-misc/curl-7.16.3[gnutls] )
	>=net-libs/miniupnpc-1.6
	>=dev-libs/glib-2.28:2
	>=x11-libs/gtk+-2.22:2
	>=dev-libs/dbus-glib-0.70"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2.6b
	sys-devel/gettext
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	sys-apps/sed"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# https://trac.transmissionbt.com/ticket/4323
	epatch "${FILESDIR}/${MY_PN}-2.33-0001-configure.ac.patch"
	epatch "${FILESDIR}/${MY_PN}-2.33-0002-config.in-4-qt.pro.patch"
	epatch "${FILESDIR}/${MY_P}-0003-system-miniupnpc.patch"

	# Fix build failure with USE=-utp, bug #290737
	epatch "${FILESDIR}/${MY_P}-noutp.patch"

	# Upstream is not interested in this: https://trac.transmissionbt.com/ticket/4324
	sed -e 's|noinst\(_PROGRAMS = $(TESTS)\)|check\1|' -i libtransmission/Makefile.am || die

	eautoreconf

	sed -i -e 's:-ggdb3::g' configure || die
}

src_configure() {
	# cli and daemon doesn't have external deps and are enabled by default
	# let's disable them

	# nls is USE is required for Gtk+ client
	econf \
		--disable-dependency-tracking \
		--disable-cli \
		--disable-daemon \
		--enable-nls \
		$(use_enable utp) \
		--enable-gtk \
		--enable-external-miniupnp
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
	elog
	elog "To enable sound emerge media-libs/libcanberra and check that at least"
	elog "some sound them is selected. For this go:"
	elog "Gnome/system/preferences/sound themes tab and 'sound theme: default'"
	elog
	if use utp; then
		ewarn
		ewarn "Since uTP is enabled ${MY_PN} needs large kernel buffers for the UDP socket."
		ewarn "Please, add into /etc/sysctl.conf following lines:"
		ewarn " net.core.rmem_max = 4194304"
		ewarn " net.core.wmem_max = 1048576"
		ewarn "and run sysctl -p"
	fi
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
