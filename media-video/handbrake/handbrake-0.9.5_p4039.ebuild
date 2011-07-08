# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
WANT_AUTOMAKE="1.9"
inherit gnome2-utils autotools

# SRC_HB="http://download.m0k.org/handbrake/contrib/"
SRC_CONTRIB="http://download.handbrake.fr/handbrake/contrib/"
DESCRIPTION="Open-source DVD to MPEG-4 converter"
HOMEPAGE="http://handbrake.fr/"
SRC_URI="http://spaceparanoids.org/gentoo/distfiles/${P}.tar.bz2
	${SRC_CONTRIB}a52dec-0.7.4.tar.gz -> a52dec-0.7.4-${P}.tar.gz
	${SRC_CONTRIB}faac-1.28.tar.gz -> faac-1.28-${P}.tar.gz
	${SRC_CONTRIB}faad2-2.7.tar.gz -> faad2-2.7-${P}.tar.gz
	${SRC_CONTRIB}ffmpeg-git-v0.7b2-406-g7b20d35.tar.bz2 -> ffmpeg-git-v0.7b2-406-g7b20d35-${P}.tar.bz2
	${SRC_CONTRIB}fontconfig-2.8.0.tar.gz -> fontconfig-2.8.0-${P}.tar.gz
	${SRC_CONTRIB}freetype-2.3.9.tar.gz -> freetype-2.3.9-${P}.tar.gz
	${SRC_CONTRIB}lame-3.98.tar.gz -> lame-3.98-${P}.tar.gz
	${SRC_CONTRIB}libass-0.9.9.tar.bz2 -> libass-0.9.9-${P}.tar.bz2
	${SRC_CONTRIB}libbluray-0.0.1-pre-213-ga869da8.tar.gz -> libbluray-0.0.1-pre-213-ga869da8-${P}.tar.gz
	${SRC_CONTRIB}libdca-r81-strapped.tar.gz -> libdca-r81-strapped-${P}.tar.gz
	${SRC_CONTRIB}libdvdnav-svn1168.tar.gz -> libdvdnav-svn1168-${P}.tar.gz
	${SRC_CONTRIB}libdvdread-svn1168.tar.gz -> libdvdread-svn1168-${P}.tar.gz
	${SRC_CONTRIB}libiconv-1.13.tar.bz2 -> libiconv-1.13-${P}.tar.bz2
	${SRC_CONTRIB}libmkv-0.6.4.1-3-g62ce8b9.tar.gz -> libmkv-0.6.4.1-3-g62ce8b9-${P}.tar.gz
	${SRC_CONTRIB}libogg-1.1.3.tar.gz -> libogg-1.1.3-${P}.tar.gz
	${SRC_CONTRIB}libsamplerate-0.1.4.tar.gz -> libsamplerate-0.1.4-${P}.tar.gz
	${SRC_CONTRIB}libtheora-1.1.0.tar.bz2 -> libtheora-1.1.0-${P}.tar.bz2
	${SRC_CONTRIB}libvorbis-aotuv_b5.tar.gz -> libvorbis-aotuv_b5-${P}.tar.gz
	${SRC_CONTRIB}libxml2-2.7.7.tar.gz -> libxml2-2.7.7-${P}.tar.gz
	${SRC_CONTRIB}mp4v2-trunk-r355.tar.bz2 -> mp4v2-trunk-r355-${P}.tar.bz2
	${SRC_CONTRIB}mpeg2dec-0.5.1.tar.gz -> mpeg2dec-0.5.1-${P}.tar.gz
	${SRC_CONTRIB}x264-r1995-c1e60b9.tar.gz -> x264-r1995-c1e60b9-${P}.tar.gz
"

# ${SRC_CONTRIB}bzip2-1.0.6.tar.gz ${SRC_CONTRIB}zlib-1.2.3.tar.gz
# ${SRC_CONTRIB}pthreads-w32-cvs20100909.tar.bz2

unset SRC_CONTRIB

LICENSE="GPL-2 GPL-3 BSD MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+css gtk"
RDEPEND="sys-libs/zlib
	css? ( media-libs/libdvdcss )
	gtk? (
			app-text/enchant
			dev-db/sqlite
			dev-libs/atk
			dev-libs/dbus-glib
			dev-libs/expat
			dev-libs/glib
			dev-libs/icu
			dev-libs/libgcrypt
			dev-libs/libgpg-error
			dev-libs/libtasn1
			dev-libs/libxml2
			dev-libs/libxslt
			net-libs/webkit-gtk
			media-libs/fontconfig
			media-libs/gst-plugins-base
			media-libs/gstreamer
			media-libs/libpng
			net-libs/gnutls
			sys-libs/glibc
			sys-libs/zlib
			virtual/jpeg
			x11-libs/cairo
			x11-libs/gdk-pixbuf
			x11-libs/gtk+:2
			x11-libs/libnotify
			x11-libs/libSM
			x11-libs/libX11
			x11-libs/pango
	)"
DEPEND="dev-lang/yasm
	dev-lang/python
	dev-util/pkgconfig
	${RDEPEND}"

# Handbrake attempts to download tarballs itself in its build system,
# so copy them to the expected location instead.
src_prepare() {
	mkdir "${S}"/download || die
	local x
	for x in ${A}; do
		# cp "${DISTDIR}"/${x} "${S}"/download/ || die "copying failed"
		cp "${DISTDIR}/${x}" "${S}/download/${x/-${P}}" \
			|| die "copying ${x} failed"
	done
}

# Don't waste time unpacking all the tarballs, when we just
# need the handbrake one.
src_unpack() {
	unpack ${P}.tar.bz2
}

src_configure() {
	# Python configure script doesn't accept all econf flags
	./configure --force --prefix=/usr \
		$(use_enable gtk) \
		|| die "configure failed"
}

src_compile() {
	emake -C build || die "failed compiling ${PN}"
}

src_install() {
	emake -C build DESTDIR="${D}" install || die "failed installing ${PN}"
	emake -C build doc || die "emake doc failed"
	dodoc AUTHORS CREDITS NEWS THANKS || die "dodoc (1) failed"
	dodoc build/doc/articles/txt/* || die "dodoc (2) failed"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
