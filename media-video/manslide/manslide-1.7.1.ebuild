# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils qt4
S="${WORKDIR}"

DESCRIPTION="KDE application that creates video slideshows."
SRC_URI="http://csgib36.ifrance.com/Manslide/${P}.tar.gz"
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=46558"
SLOT="0"

LICENSE="GPL"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	>=media-sound/vorbis-tools-1.0.1
	>=media-sound/sox-13.0.0
	>=media-video/tcmplex-panteltje-0.4.7
	>=media-video/mjpegtools-1.8.0
	>=media-gfx/imagemagick-6.3.2.9
	media-video/mplayer
	( $(qt4_min_version 4.2.0) )
	"

RDEPEND="${DEPEND}"

src_compile() {
        cd ${S}/Manslide-${PV}
        [ -d "$QTDIR/etc/settings" ] && addwrite "$QTDIR/etc/settings"
        addpredict "$QTDIR/etc/settings"
        qmake Manslide.pro || die
        emake || die
}

src_install() {

	dodir /usr/bin
	exeinto /usr/bin
	doexe Manslide-${PV}/Manslide

	dodir /usr/share/manslide
	dodir /usr/share/applnk/Multimedia

        echo "[Desktop Entry]
        Encoding=UTF-8
        Type=Application
        Exec=Manslide
        Icon=manslide.png
        Comment=Simple slideshow creator
        Name=Manslide
        Terminal=false
        GenericName=Slideshow Creator" > ${D}/usr/share/applnk/Multimedia/manslide.desktop

	dodir /usr/share/icons
	insinto /usr/share/icons
        newins ${S}/Manslide-${PV}/Interface/renderer.png manslide.png

}
