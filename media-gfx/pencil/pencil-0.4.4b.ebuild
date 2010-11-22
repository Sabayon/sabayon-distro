# Copyright 1999-2010 Sabayon Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="2"

inherit qt4-r2

DESCRIPTION="Animation/drawing software package that lets you create traditional hand-drawn animations"
HOMEPAGE="http://www.pencil-animation.org"
SRC_URI="mirror://sourceforge/pencil-planner/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND="x11-libs/qt-opengl
	 x11-libs/qt-gui:4
	 >=media-libs/ming-0.4.3"

DEPEND="${RDEPEND}
	app-arch/unzip"

S="${WORKDIR}/${P}-source"

src_prepare() {
	sed -i s:SWFSprite:SWFMovieClip:g src/external/flash/flash.{cpp,h} || die "sed failed"
}

src_install() {
	dobin Pencil || die "doexe failed"

 	dodoc README TODO || die "dodoc failed"

	newicon "${S}"/icons/icon.png ${PN}.png
	make_desktop_entry Pencil Pencil ${PN}.png Graphics
}
