# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit qt4 eutils

DESCRIPTION="Pencil is an animation/drawing software package that lets you create traditional hand-drawn animation (cartoon) using both bitmap and vector
graphics"
HOMEPAGE="http://www.les-stooges.org/pascal/pencil"
SRC_URI="mirror://sourceforge/pencil-planner/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"

IUSE=""

RDEPEND=">=x11-libs/qt-4 \
		>=media-libs/ming-0.4.0_beta5"
DEPEND="${RDEPEND} \
		app-arch/unzip"

S=${WORKDIR}/${P}-source

src_compile() {
	eqmake4 || die "eqmake4 failed"
	emake || die "emake failed"
}

src_install() {
	mv Pencil pencil
	dobin pencil || die "dobin failed"
	mv icons/icon.png icons/pencil.png
	doicon icons/pencil.png
	make_desktop_entry "${PN}" "${PN}" "${PN}.png" "Graphics;2DGraphics;RasterGraphics;" || \
		die "failed to make desktop entry."
}

