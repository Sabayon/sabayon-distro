# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-9999.ebuild,v 1.6 2006/07/09 17:00:52 brix Exp $

inherit qt4

DESCRIPTION="Pencil is an animation/drawing software package that lets you create traditional hand-drawn animation (cartoon) using both bitmap and vector
graphics"
HOMEPAGE="http://www.les-stooges.org/pascal/pencil"
SRC_URI="mirror://sourceforge/pencil-planner/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND="x11-libs/qt-core
	 x11-libs/qt-opengl
	 x11-libs/qt-gui
	 media-libs/ming"

DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/${P}-source

src_compile() {
	eqmake4 || die "eqmake4 failed"
	emake || die "emake failed"
}

src_install() {
	mv Pencil pencil
	dobin pencil || die "dobin failed"
	doicon icons/icon.png
}

