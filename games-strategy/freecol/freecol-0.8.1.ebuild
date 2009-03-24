# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/freecol/freecol-0.7.4.ebuild,v 1.1 2008/06/16 20:48:23 nyhm Exp $

WANT_ANT_TASKS="ant-nodeps"
inherit eutils java-pkg-2 java-ant-2 games

DESCRIPTION="An open source clone of the game Colonization"
HOMEPAGE="http://www.freecol.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="dev-java/higlayout"
DEPEND="${RDEPEND}
	test? (
		dev-java/ant-junit
		dev-java/ant-trax
	)
	>=virtual/jdk-1.6"
RDEPEND="${RDEPEND}
	>=virtual/jre-1.6"

S=${WORKDIR}/${PN}

pkg_setup() {
	games_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -fv $(find . -name '*.jar')
	java-pkg_jar-from --into jars higlayout
	epatch "${FILESDIR}"/${P}-home.patch
	sed -i \
		-e "/Class-Path/s:jars/.*\":$(java-pkg_getjars higlayout)\":" \
		build.xml \
		|| die "sed failed"
}

src_compile() {
	eant
}

src_test() {
	java-pkg_jar-from --into test/lib junit
	ANT_TASKS="ant-junit ant-trax ant-nodeps" eant testall
}

src_install () {
	java-pkg_jarinto "${GAMES_DATADIR}"/${PN}
	java-pkg_dojar FreeCol.jar
	java-pkg_dolauncher ${PN} \
		-into "${GAMES_PREFIX}" \
		--pwd "${GAMES_DATADIR}"/${PN} \
		--java_args -Xmx512M
	insinto "${GAMES_DATADIR}"/${PN}
	doins -r data || die "doins failed"
	doicon ${PN}.xpm
	make_desktop_entry ${PN} FreeCol
	dodoc README
	prepgamesdirs
}
