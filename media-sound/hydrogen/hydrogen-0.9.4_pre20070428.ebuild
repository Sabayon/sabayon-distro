# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/hydrogen/hydrogen-0.9.3-r1.ebuild,v 1.2 2007/02/17 00:52:57 flameeyes Exp $

inherit eutils autotools qt4 multilib

MY_P=${PN}-20070428
DESCRIPTION="Linux Drum Machine"
HOMEPAGE="http://hydrogen.sourceforge.net/"
SRC_URI="http://www.hydrogen-music.org/download/development/sources/${MY_P}.tar.gz"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa debug jack ladspa oss portaudio"

RDEPEND="dev-libs/libxml2
	media-libs/libsndfile
	media-libs/audiofile
	media-libs/flac
	dev-libs/libtar
	$(qt4_min_version 4.2)
	portaudio? ( media-libs/portaudio )
	alsa? ( media-libs/alsa-lib )
	jack? ( media-sound/jack-audio-connection-kit )
	ladspa? ( media-libs/liblrdf )"

src_unpack() {
	unpack ${A}

	# apply configure patch
	cd ${S}
	epatch ${FILESDIR}/${PN}-fix-qt4-paths.patch
	sed -i 's/^prefix=.*/prefix=\/usr/' configure
}

src_compile() {
	cd ${S}
	QTDIR=/usr/lib/qt4 econf || die "Failed configuring hydrogen!"
	make || die "Failed making hydrogen!"
}

src_install() {
	make INSTALL_ROOT=${D} install || die "make install failed"
}
