# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit transmission-2.41

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Gtk+ UI"
LICENSE="MIT GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="utp"

RDEPEND="
	>=net-libs/miniupnpc-1.6
	>=dev-libs/glib-2.28:2
	>=x11-libs/gtk+-2.22:2
	>=dev-libs/dbus-glib-0.70"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.40"

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
