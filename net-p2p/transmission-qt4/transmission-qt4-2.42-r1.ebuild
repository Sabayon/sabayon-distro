# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit transmission-2.42

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Qt4 UI"
KEYWORDS="~amd64 ~x86"
IUSE="kde nls"

RDEPEND="x11-libs/qt-gui:4[dbus]"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext
		>=dev-util/intltool-0.40 )"

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
