# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils

MY_PN="atunes"
DESCRIPTION="aTunes is a full-featured audio player and manager."
HOMEPAGE="http://www.atunes.org"
SRC_URI="http://downloads.sourceforge.net/atunes/${MY_PN}-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="mplayer mp3 flac ogg"
# TODO - Package depends on either mplayer or xine. 
# idl0r helped with the current implementation. Hopefully I got it right!
DEPEND=">=virtual/jre-1.6.0
		virtual/cdrtools
	   	mplayer? ( >=media-video/mplayer-1.0_rc2 )
	   	!mplayer? ( >=media-libs/xine-lib-1.1 )
		mp3? ( >=media-sound/lame-3.98 )
		flac? ( >=media-libs/flac-1.2 )
		ogg? ( >=media-sound/vorbis-tools-1.2 )"
RDEPEND="${DEPEND}"
S=${WORKDIR}/${MY_PN}-${PV}-SNAPSHOT

src_install() {
	# aTunes is installed into $atunes_home by simply copying the archive
	# contents. The ebuild adds a symbolic link to the executable and a
	# desktop shortcut.
	atunes_home=/usr/share/atunes

	epatch ${FILESDIR}/change-dir.patch

	insinto ${atunes_home} 
	exeinto ${atunes_home} 

	doins *
	cp -R lib ${D}${atunes_home}
	doexe aTunes.sh 
	dosym ${atunes_home}/aTunes.sh /usr/bin/atunes

	# Install desktop shortcut
	mkdir -p ${D}/usr/share/pixmaps
	insinto /usr/share/pixmaps
	atunes_icon=atunes.png
	doins ${atunes_icon} 
	make_desktop_entry "atunes" "aTunes" "${atunes_icon}" "AudioVideo;Player"
}
