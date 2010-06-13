# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="Digital photo editor and collection manager"
HOMEPAGE="http://kornelix.squarespace.com/fotoxx/"
SRC_URI="http://kornelix.squarespace.com/storage/downloads/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-libs/gtk+
	media-libs/tiff"
RDEPEND="${DEPEND}
	media-libs/exiftool
	media-gfx/ufraw
	x11-misc/xdg-utils"

src_compile() {
	PREFIX=/usr emake || die "emake failed"
}

src_install() {
	cd "${S}"
	dobin fotoxx
	insinto /usr/share/${PN}
	doins -r locales icons
	newman doc/${PN}.man ${PN}.1
	dodoc doc/{CHANGES,README,TRANSLATIONS}
	dohtml -r doc/userguide-en.html doc/images
	make_desktop_entry ${PN} "Fotoxx" ${PN} "Application;Graphics;Photography;"
	doicon icons/fotoxx.png
}
