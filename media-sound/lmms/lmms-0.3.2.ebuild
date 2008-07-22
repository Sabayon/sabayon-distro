# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="free alternative to popular programs such as FruityLoops, Cubase and Logic"
HOMEPAGE="http://lmms.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="alsa debug flac jack ladspa oss samplerate sdl vorbis vst"

DEPEND="=x11-libs/qt-3.3*
	vorbis? ( media-libs/libvorbis )
	alsa? ( media-libs/alsa-lib )
	sdl? ( media-libs/libsdl
		>=media-libs/sdl-sound-1.0.1 )
	samplerate? ( media-libs/libsamplerate )
	jack? ( >=media-sound/jack-audio-connection-kit-0.99.0 )
	flac? ( media-libs/flac )
	ladspa? ( media-libs/ladspa-sdk )
	vst? ( app-emulation/wine
		media-plugins/vst-headers )"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	if use vst ; then
		cp /usr/include/vst/{AEffect.h,aeffectx.h} "${WORKDIR}/${P}/include/"
	fi
}

src_compile() {
	econf \
		$(use_with alsa asound) \
		$(use_with flac) \
		$(use_with ladspa) \
		$(use_with vorbis) \
		$(use_with samplerate libsrc) \
		$(use_with oss) \
		$(use_with sdl) \
		$(use_with sdl sdlsound) \
		$(use_with jack) \
		$(use_with vst) \
		$(use_with debug) \
		--enable-hqsinc || die "econf failed"
	if use vst ; then
		emake -j1 || die "emake failed"
	else
		emake || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	newicon usr/share/lmms/themes/default/icon.png ${PN}.png
	make_desktop_entry ${PN} "Linux Multimedia Studio" ${PN}.png "AudioVideo;Audio;AudioVideoEditing;Qt"
	dodoc README AUTHORS ChangeLog TODO
}
