# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/alsa-plugins/alsa-plugins-1.0.11.ebuild,v 1.6 2006/07/03 01:28:25 vapier Exp $

inherit libtool autotools eutils

DESCRIPTION="ALSA extra plugins"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/plugins/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="jack ffmpeg libsamplerate"

# It could support polypaudio if it was in portage
RDEPEND=">=media-libs/alsa-lib-1.0.11
	jack? ( >=media-sound/jack-audio-connection-kit-0.98 )
	ffmpeg? ( media-video/ffmpeg )
	libsamplerate? ( media-libs/libsamplerate )
	!media-plugins/alsa-jack"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-automagic.patch"
	eautoreconf

	elibtoolize
}

src_compile() {
	econf \
		$(use_enable jack) \
		$(use_enable libsamplerate samplerate) \
		$(use_enable ffmpeg avcodec) \
		--disable-polypaudio \
		--disable-dependency-tracking \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install

	cd "${S}/doc"
	dodoc upmix.txt vdownmix.txt README-pcm-oss
	use jack && dodoc README-jack
	use libsamplerate && dodoc samplerate.txt
}

