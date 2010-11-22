# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-9999.ebuild,v 1.6 2006/07/09 17:00:52 brix Exp $

EAPI="2"

inherit qt4

DESCRIPTION="Pencil is an animation/drawing software package that lets you create traditional hand-drawn animation (cartoon) using both bitmap and vector
graphics"
HOMEPAGE="http://www.les-stooges.org/pascal/pencil"
SRC_URI="mirror://sourceforge/pencil-planner/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND="x11-libs/qt-opengl
	 x11-libs/qt-gui:4
	 >=media-libs/ming-0.4.3"

DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/${P}-source

src_configure() {
	sed -i s:SWFSprite:SWFMovieClip:g src/external/flash/flash.{cpp,h}
}

src_compile() {
	eqmake4 || die "eqmake4 failed"
	emake || die "emake failed"
}

src_install() {
	exeinto /usr/local/bin
	doexe Pencil || die "doexe failed"

 	dodoc README TODO

	mv "${S}"/icons/icon.png "${S}"/icons/${PN}.png
	doicon "${S}"/icons/${PN}.png || die "doicon failed"
	make_desktop_entry Pencil Pencil ${PN}.png Graphics
}
