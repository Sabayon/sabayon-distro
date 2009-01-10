# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils qt4

DESCRIPTION="KDE application that creates video slideshows."
SRC_URI="http://ftp.riken.go.jp/pub/FreeBSD/distfiles/${P}.tar.gz"
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=72739"
SLOT="0"

LICENSE="GPL"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=media-sound/vorbis-tools-1.0.1
	>=media-sound/sox-13.0.0
	>=media-video/tcmplex-panteltje-0.4.7
	>=media-video/mjpegtools-1.8.0
	>=media-gfx/imagemagick-6.3.2.9
	media-video/mplayer
	x11-libs/qt:4
	"

RDEPEND="${DEPEND}"

src_compile() {
	ewarn "This package is *NOT* Supported by the Sabayon Devs!"

	eqmake4 Manslide.pro
        emake || die
}

src_install() {
	dodir /usr/bin
	exeinto /usr/bin
	doexe Manslide

	make_desktop_entry Manslide Manslide manslide "Qt;AUdioVideo;Video"
	dodir /usr/share/icons
	insinto /usr/share/icons
        newins ${S}/Interface/renderer.png manslide.png
}

pkg_postinst() {
    ewarn "This package is *NOT* Supported by the Sabayon Devs!"
    ewarn ""
    ewarn "Please report bugs upstream"
}

