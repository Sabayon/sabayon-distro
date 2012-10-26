# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
TRANSMISSION_ECLASS_VERSION_OK=2.71
inherit eutils transmission-2.71

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Qt4 UI"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-libs/qt-core:4
	x11-libs/qt-gui:4[dbus]
"
DEPEND="${RDEPEND}"

src_install() {
	pushd qt >/dev/null
	dodoc README.txt

	dobin transmission-qt
	doman transmission-qt.1

	domenu ${MY_PN}-qt.desktop || die

	local res
	for res in 16 22 24 32 48; do
		insinto /usr/share/icons/hicolor/${res}x${res}/apps
		newins icons/hicolor_apps_${res}x${res}_${MY_PN}.png ${MY_PN}-qt.png
	done

	insinto /usr/share/kde4/services
	doins "${T}"/${MY_PN}-magnet.protocol

	insinto /usr/share/qt4/translations
	doins translations/*.qm
	popd >/dev/null
}
