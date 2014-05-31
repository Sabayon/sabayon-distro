# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils transmission-2.83

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Gtk+ UI"
KEYWORDS="~amd64 ~x86"
IUSE="ayatana"

RDEPEND="
	>=dev-libs/dbus-glib-0.100:=
	>=dev-libs/glib-2.32:2=
	>=x11-libs/gtk+-3.4:3=
	ayatana? ( >=dev-libs/libappindicator-0.4.90:3= )
	!net-p2p/transmission-gtk+
"

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
