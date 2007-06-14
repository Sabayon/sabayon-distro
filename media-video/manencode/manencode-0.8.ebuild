# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils
S="${WORKDIR}/Manencode"

DESCRIPTION="Transcode your videos !"
SRC_URI="http://csgib36.ifrance.com/Manencode/Manencode-${PV}.tar.gz"
HOMEPAGE="http://www.kde-apps.org/content/show.php/Manencode?content=52228"

LICENSE="GPL"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	>=media-video/transcode-1.0
	>=media-video/mplayer-1.0_rc1
	>=x11-libs/qt-4.2.2
	"

RDEPEND="${DEPEND}"

src_compile() {
        cd ${S}
        [ -d "$QTDIR/etc/settings" ] && addwrite "$QTDIR/etc/settings"
        addpredict "$QTDIR/etc/settings"
        qmake Manencode.pro || die
        emake || die
}

src_install() {

	dodir /usr/bin
	exeinto /usr/bin
	doexe Manencode-${PV}/Manencode

	dodir /usr/share/manencode
	dodir /usr/share/applnk/Multimedia

        echo "[Desktop Entry]
        Encoding=UTF-8
        Type=Application
        Exec=Manencode
        Icon=manencode.png
        Comment=Transcode your video
        Name=Manencode
        Terminal=false
        GenericName=Manencode Editor" > ${D}/usr/share/applnk/Multimedia/manencode.desktop

	dodir /usr/share/icons
	insinto /usr/share/icons
        newins ${S}/Manencode-${PV}/Interface/executer.png manencode.png

}
