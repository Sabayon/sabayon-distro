# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/tunepimp/tunepimp-0.5.0.ebuild,v 1.2 2006/10/19 20:15:46 flameeyes Exp $

inherit eutils distutils perl-app

MY_P="lib${P}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="TunePimp is a library to create MusicBrainz enabled tagging applications."
HOMEPAGE="http://www.musicbrainz.org/products/tunepimp"
SRC_URI="http://ftp.musicbrainz.org/pub/musicbrainz/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
# Most use flags were void as not deterministic - needs a patch sooner or later.
#IUSE="flac mp3 readline perl python vorbis"
IUSE="python"

RDEPEND="sys-libs/zlib
	dev-libs/expat
	net-misc/curl
	~media-libs/flac-1.1.2
	media-libs/libmad
	>=media-libs/musicbrainz-2.1.0
	media-libs/libofa
	media-libs/libvorbis
	!media-sound/trm
	sys-libs/readline"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_compile() {
	# broken script, install fails
	sed -i -e "s: tta::" configure.in
	libtoolize --copy --force
	autoheader
	automake --foreign --add-missing --copy --include-deps
	aclocal
	autoconf

	econf || die "configure failed"
	emake || die "emake failed"
	# disabled as broken with Perl 5.8.8
	#if use perl; then
	#	cd ${S}/perl/tunepimp-perl
	#	perl-app_src_compile || die "perl module failed to compile"
	#fi
}

src_install() {
	cd ${S}
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog INSTALL README TODO
	if use python; then
		cd ${S}/python
		distutils_src_install
		insinto /usr/share/doc/${PF}/examples/
		doins examples/*
	fi
# 	if use perl; then
# 		cd ${S}/perl/tunepimp-perl
# 		perl-module_src_install || die "perl module failed to install"
# 		insinto /usr/share/doc/${PF}/examples/
# 		doins examples/*
# 	fi
}
