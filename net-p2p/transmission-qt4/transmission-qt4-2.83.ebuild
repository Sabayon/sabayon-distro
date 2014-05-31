# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
TRANSMISSION_PATCHES=(
	# Fix for broken translations path
	"${FILESDIR}"/${PN}-2.80-translations-path-fix.patch
)
inherit eutils transmission-2.83

DESCRIPTION="A Fast, Easy and Free BitTorrent client - Qt4 UI"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-qt/qtcore:4=
	dev-qt/qtgui:4=
	dev-qt/qtdbus:4=
"
DEPEND="${RDEPEND}"

src_install() {
	pushd qt >/dev/null
	dodoc README.txt

	dobin transmission-qt
	doman transmission-qt.1

	domenu ${MY_PN}-qt.desktop || die

	local res
	for res in 16 22 24 32 48 64 72 96 128 192 256; do
		doicon -s ${res} icons/hicolor/${res}x${res}/${MY_PN}-qt.png
	done
	doicon -s scalable icons/hicolor/scalable/${MY_PN}-qt.svg

	insinto /usr/share/qt4/translations
	doins translations/*.qm
	popd >/dev/null
}
