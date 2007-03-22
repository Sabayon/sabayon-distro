# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit autotools eutils libtool

IUSE=""
DESCRIPTION="Toolkit for exploring new uses of video and new human-computer interaction techniques"
HOMEPAGE="http://insitu.lri.fr/~roussel/projects/nucleo"
SRC_URI="
	http://www.sabayonlinux.org/distfiles/x11-wm/${P}/${P}.tar.bz2
	"

LICENSE="LGPL-2"
SLOT="0"
RESTRICT="nomirror"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"

DEPEND="
	x11-base/xorg-server
	x11-libs/libXi
	media-libs/jpeg
	media-libs/libpng
	>=media-libs/mesa-6.5
	>=media-libs/freetype-2.1
	>=net-dns/avahi-0.6.15
	>=x11-libs/qt-4.0
	media-video/ffmpeg
	"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/${PN}-20061224-64bit-fixes.patch
	epatch ${FILESDIR}/${P}-fixdnssd.patch
	epatch ${FILESDIR}/${P}-32bit.patch
	epatch ${FILESDIR}/${P}-fixplugins.patch
	epatch ${FILESDIR}/${P}-avahi.patch

}

src_compile() {
	cd ${S}

	eautoconf || die "autoconf failed"
	elibtoolize || die "autoconf failed"	
	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
