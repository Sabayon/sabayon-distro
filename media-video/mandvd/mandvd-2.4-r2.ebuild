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

DEPEND="=x11-libs/qt-3*
	>=media-libs/xine-lib-1.1.2-r2
	>=media-video/dvd-slideshow-0.7.5
	>media-sound/lame-3.96
	>=media-video/dvdauthor-0.6.11
	>=media-video/mjpegtools-1.8.0-r1
	>=media-libs/netpbm-10.34
	>=media-video/transcode-1.0.2-r2"

RDEPEND="${DEPEND}
	>=app-cdr/dvd+rw-tools-5.21.4.10.8
	"



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
