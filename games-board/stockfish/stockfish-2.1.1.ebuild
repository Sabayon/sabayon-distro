# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit games eutils versionator toolchain-funcs

DESCRIPTION="A UCI chess engine"
HOMEPAGE="http://www.stockfishchess.com/"
SRC_URI="http://cl.ly/43170W2W3f2F021b0N42/content -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="app-arch/unzip"

S="${WORKDIR}/${PN}-$(delete_all_version_separators)-ja/src"

src_compile() {
	emake ARCH=general-32 || die "emake failed"
}

src_install() {
	dogamesbin ${PN} || die "dogamesbin failed"
	dodoc ../Readme.txt ../Copying.txt || die "dodoc failed"
	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	elog
	elog "Note: The opening book hasn't been installed. If you want it, just"
	elog "      download it from ${HOMEPAGE}."
	elog "      In most cases you take now your xboard compatible application,"
	elog "      (xboard, eboard, knights) and just play chess against computer"
	elog "      opponent. Have fun."
	elog
}

