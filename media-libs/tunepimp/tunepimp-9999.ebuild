# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils subversion

DESCRIPTION="Client library to create MusicBrainz enabled tagging applications"
HOMEPAGE="http://www.musicbrainz.org/products/tunepimp"

ESVN_REPO_URI="http://svn.musicbrainz.org/libtunepimp/trunk/"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples flac mp3 readline python vorbis"

RDEPEND=">=media-libs/musicbrainz-2.1.0
	flac? ( media-libs/flac )
	vorbis? ( media-libs/libvorbis )
	readline? ( sys-libs/readline )
	mp3? ( media-libs/libmad )
	!media-sound/trm
	>=media-libs/libofa-0.9
	!<=media-libs/tunepimp-0.5.0-r0"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/trunk"

src_compile() {
	#stupid configure script has no relevant --enable options
	econf || die "configure failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog INSTALL README TODO
	if use python; then
		cd ${S}/python
		distutils_src_install
		if use examples ; then
			docinto examples
			dodoc examples/*
		fi
	fi
}
