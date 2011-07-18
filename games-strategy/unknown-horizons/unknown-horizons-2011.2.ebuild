# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2:2.7"
PYTHON_USE_WITH="sqlite"

inherit distutils games
DESCRIPTION="Anno-like real time strategy game"
HOMEPAGE="http://www.unknown-horizons.org/"

SRC_URI="mirror://sourceforge/unknownhorizons/${P}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

DEPEND="dev-python/pyyaml
	=games-engines/fife-0.3.2.2
	dev-python/python-distutils-extra"

RDEPEND="$DEPEND"

S="${WORKDIR}"/${PN}

src_compile() {
	distutils_src_compile build_i18n
}

src_install() {
	# FIXME: exe and data-files goes into wrong place, games.gentoo.org policy
	# violation
	distutils_src_install
	prepgamesdirs
}
