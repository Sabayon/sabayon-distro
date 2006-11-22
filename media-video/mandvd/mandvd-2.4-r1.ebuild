# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License, v2 or later
# Maintainer: Pascal Fleury <fleury@users.sourceforge.net>
# $Header:$

S="${WORKDIR}"

DESCRIPTION="This is a program to simply create DVD Video"
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=38347"
LICENSE="GPL-2"
SRC_URI="http://csgib36.ifrance.com/FTP/${PN}-${PV}src.tar.gz"
RESTRICT="nomirror"
IUSE=""
KEYWORDS="~x86 ~amd64"

DEPEND=">=qt-3.3.3
	>=xine-lib-0.99.4
	>=dvd-slideshow-0.7.5
	>media-sound/lame-3.96
	>=dvdauthor-0.6.11
	>=mjpegtools-1.8.0
	>=netpbm-10.29
	>=media-video/transcode-1.0.2
	>=dvd+rw-tools-5.21.4"

RDEPEND="$DEPEND"



src_compile() {
        addwrite "${QTDIR}/etc/settings"
	cd ${S}/ManDVD-${PV}src
	/usr/qt/3/bin/qmake mandvd.pro
	emake 
}

src_install () {
	exeinto /usr/bin
	doexe ManDVD-${PV}src/mandvd
}
