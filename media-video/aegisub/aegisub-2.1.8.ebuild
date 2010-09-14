# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

WX_GTK_VER="2.8"
inherit autotools eutils wxwidgets

MY_PV="${PV/_pre/-dev-r}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Advanced SSA/ASS subtitle editor"
HOMEPAGE="http://www.aegisub.net/"
SRC_URI="http://ftp.aegisub.org/pub/archives/releases/source/${MY_P}.tar.gz
		 http://ftp2.aegisub.org/pub/archives/releases/source/${MY_P}.tar.gz
		 http://www.mahou.org/~verm/aegisub/${MY_P}.tar.gz
		 http://www.mahou.org/~verm/aegisub/archives/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa debug ffmpeg lua nls openal oss perl portaudio pulseaudio spell ruby"

RDEPEND="=x11-libs/wxGTK-2.8*[X,opengl]
	media-libs/libass
	media-libs/fontconfig
	media-libs/freetype

	alsa? (	media-libs/alsa-lib )
	portaudio? ( =media-libs/portaudio-19* )
	pulseaudio? ( media-sound/pulseaudio )
	openal? ( media-libs/openal )

	perl? ( dev-lang/perl )
	ruby? ( dev-lang/ruby )
	lua? ( dev-lang/lua )

	spell? ( app-text/hunspell )
	ffmpeg? ( >=media-video/ffmpeg-0.5_p18642 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	media-gfx/imagemagick
	dev-libs/glib"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-do-not-verify-audiolibs.patch
	eautoreconf
}

src_configure() {
	econf $(use_with alsa) \
		$(use_with oss) \
		$(use_with portaudio) \
		$(use_with pulseaudio) \
		$(use_with openal) \
		$(use_with lua) \
		$(use_with ruby) \
		$(use_with perl) \
		$(use_with ffmpeg provider-video ffmpegsource) \
		$(use_with ffmpeg provider-audio ffmpegsource) \
		$(use_with spell hunspell) \
		$(use_enable debug) \
		$(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install faild"
}
