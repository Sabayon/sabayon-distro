# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

inherit autotools

DESCRIPTION="A DJ console for ShoutCast/IceCast streaming"
HOMEPAGE="http://www.onlymeok.nildram.co.uk/"
SRC_URI="mirror://sourceforge/idjc/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="aac ffmpeg flac mp3 mp3-streaming mp3-tagging speex"

RDEPEND=">=dev-lang/python-2.4
	dev-python/pygtk
	media-libs/libsamplerate
	media-libs/libshout
	media-libs/libsndfile
	media-sound/jack-audio-connection-kit
	media-sound/vorbis-tools
	aac? ( media-libs/faad2 )
	ffmpeg? ( virtual/ffmpeg )
	flac? ( media-libs/flac )
	mp3? ( media-libs/libmad )
	mp3-streaming? ( media-sound/lame )
	mp3-tagging? ( dev-python/eyeD3 )
	speex? ( media-libs/speex )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9.0"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# oldest version is >=media-video/ffmpeg-0.4.9_p20080326 anyway...
	for x in $(find . -name "*.[ch]" -print0 | xargs -0 grep -l "#include <ffmpeg/avcodec.h>" ); do
		sed -i -e "/avcodec\.h/s:ffmpeg:libavcodec:" $x;
	done
	#if has_version \>=media-video/ffmpeg-0.4.9_p20080326 ; then
		#for x in $(find . -name "*.[ch]" -print0 | xargs -0 grep -l "#include <ffmpeg/avcodec.h>" ); do
			#sed -i -e "/avcodec\.h/s:ffmpeg:libavcodec:" $x;
		#done
		#for x in $(find . -name "*.[ch]" -print0 | xargs -0 grep -l "#include <ffmpeg/avformat.h>"); do
			#sed -i -e "/avformat\.h/s:ffmpeg:libavformat:" $x;
		#done
	#fi

	eautoreconf
}

src_compile() {
	econf $(use_enable aac mp4) $(use_enable ffmpeg) $(use_enable mp3 mad) \
		$(use_enable mp3-streaming lame)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
}

pkg_postinst() {
	einfo "In order to run idjc you first need to have a JACK sound server running."
	einfo "With all audio apps closed and sound servers on idle type the following:"
	einfo "jackd -d alsa -r 44100 -p 2048"
	einfo "Alternatively to have JACK start automatically when launching idjc:"
	einfo "echo \"/usr/bin/jackd -d alsa -r 44100 -p 2048\" >~/.jackdrc"
	einfo ""
	einfo "If you want to announce tracks playing in idjc to IRC using X-Chat,"
	einfo "copy or link /usr/share/idjc/idjc-announce.py to your ~/.xchat2/ dir."
}
