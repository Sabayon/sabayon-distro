# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit fdo-mime

DESCRIPTION="foobar2000-like music player."
HOMEPAGE="http://deadbeef.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2 ZLIB"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="aac adplug alsa cdda cover curl dts encode ffmpeg flac gme +gtk
	hotkeys lastfm libnotify libsamplerate m3u mac midi mms mp3 musepack
	nls null oss pulseaudio shellexec sid sndfile supereq threads tta
	vorbis vtx wavpack zip"

REQUIRED_USE="encode? ( gtk )
	cover? ( curl )
	lastfm? ( curl )"

DEPEND="
	gtk? ( x11-libs/gtk+:2 )
	alsa? ( media-libs/alsa-lib )
	vorbis? ( media-libs/libvorbis )
	curl? ( net-misc/curl )
	mp3? ( media-libs/libmad )
	flac? ( media-libs/flac )
	wavpack? ( media-sound/wavpack )
	sndfile? ( media-libs/libsndfile )
	cdda? ( dev-libs/libcdio media-libs/libcddb )
	ffmpeg? ( virtual/ffmpeg )
	hotkeys? ( x11-libs/libX11 )
	libnotify? ( sys-apps/dbus )
	pulseaudio? ( media-sound/pulseaudio )
	aac? ( media-libs/faad2 )
	midi? ( media-sound/timidity-freepats )
	zip? ( sys-libs/zlib )
	libsamplerate? ( media-libs/libsamplerate )
	"
RDEPEND="${DEPEND}"

src_prepare() {
	if use midi; then
		# set default gentoo path
		sed -e 's;/etc/timidity++/timidity-freepats.cfg;/usr/share/timidity/freepats/timidity.cfg;g' \
			-i "${S}/plugins/wildmidi/wildmidiplug.c"
	fi
}

src_configure() {
	my_config="$(use_enable nls)
		$(use_enable threads)
		$(use_enable null nullout)
		$(use_enable alsa)
		$(use_enable oss)
		$(use_enable gtk gtkui)
		$(use_enable aac)
		$(use_enable adplug)
		$(use_enable cdda)
		$(use_enable cover artwork)
		$(use_enable curl vfs-curl)
		$(use_enable dts dca)
		$(use_enable encode converter)
		$(use_enable ffmpeg)
		$(use_enable flac)
		$(use_enable gme)
		$(use_enable hotkeys)
		$(use_enable lastfm lfm)
		$(use_enable libnotify notify)
		$(use_enable libsamplerate src)
		$(use_enable m3u)
		$(use_enable mac ffap)
		$(use_enable midi wildmidi)
		$(use_enable mms)
		$(use_enable mp3 mad)
		$(use_enable musepack)
		$(use_enable pulseaudio pulse)
		$(use_enable shellexec)
		$(use_enable sid)
		$(use_enable sndfile)
		$(use_enable supereq)
		$(use_enable tta)
		$(use_enable vorbis)
		$(use_enable vtx)
		$(use_enable wavpack)
		$(use_enable zip vfs-zip)"

	econf ${my_config}
}
