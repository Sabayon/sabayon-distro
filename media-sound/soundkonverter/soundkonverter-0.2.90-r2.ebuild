# Copyright 2003-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde eutils

DESCRIPTION="SoundKonverter: a frontend to various audio converters for KDE"
HOMEPAGE="http://kde-apps.org/content/show.php?content=29024"
SRC_URI="http://kaligames.de/downloads/soundkonverter/${PN}-${PV}.tar.bz2"
LICENSE="GPL"
SLOT="0"
RESTRICT="nomirror"

KEYWORDS="~x86 ~amd64"
IUSE="lame vorbis flac ffmpeg musepack kdeenablefinal arts aac"

DEPEND=">=media-libs/taglib-1.4
	>=x11-libs/qt-3.3.4"

RDEPEND="
	lame?     ( >=media-sound/lame-3.96 )
	vorbis?   ( >=media-sound/vorbis-tools-1.0 )
	flac?     ( >=media-libs/flac-1.1.1 )
	ffmpeg?   ( >=media-video/ffmpeg-0.4.8 )
	musepack? ( >=media-sound/musepack-tools-1.15u )
	aac?      ( media-libs/libmp4v2 )
	"

need-kde 3.5

PATCHES="${FILESDIR}/${P}-${V}-makefile.patch"

src_unpack() {
	kde_src_unpack
}

src_compile() {
	
	append-flags -fno-inline
	local myconf= " $(use_with aac mp4v2)
			$(use_enable kdeenablefinal final)
			$(use_with arts arts)
			"
	kde_src_compile || die "Compile error"
}

src_install() {
	kde_src_install || die "Installation failed"
	mv ${D}/usr/share/doc/HTML ${D}/usr/share/doc/${PF}
}

pkg_postinst() {
	echo -e "\n\n"
	elog "  The audio USE flags are for your convience, but are not required."
	elog "	For AmaroK users there is a script included with this package."
	elog "	You can enable it with the Script Manager tool in Amarok."
	echo -e "\n\n"
}

