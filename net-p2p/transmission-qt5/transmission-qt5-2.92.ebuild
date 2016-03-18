# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils transmission-2.92

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Qt5 UI"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	!net-p2p/transmission-qt4
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5"

src_install() {
	pushd qt >/dev/null || die
	dodoc README.txt

	dobin transmission-qt
	doman transmission-qt.1

	domenu ${MY_PN}-qt.desktop

	local res
	for res in 16 22 24 32 48 64 72 96 128 192 256; do
		doicon -s ${res} icons/hicolor/${res}x${res}/transmission-qt.png
	done
	doicon -s scalable icons/hicolor/scalable/transmission-qt.svg

	insinto /usr/share/qt5/translations
	doins translations/*.qm
	popd >/dev/null || die
}
