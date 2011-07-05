# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnome2-utils autotools

SRC_HB="http://download.m0k.org/handbrake/contrib/"
DESCRIPTION="Open-source DVD to MPEG-4 converter"
HOMEPAGE="http://handbrake.fr/"
SRC_URI="http://spaceparanoids.org/gentoo/distfiles/${P}.tar.bz2
		${SRC_HB}a52dec-0.7.4.tar.gz -> a52dec-0.7.4-${P}.tar.gz
		${SRC_HB}faac-1.28.tar.gz
		${SRC_HB}ffmpeg-git-v0.7b2-406-g7b20d35.tar.bz2
		${SRC_HB}fontconfig-2.8.0.tar.gz
		${SRC_HB}freetype-2.3.9.tar.gz
		${SRC_HB}lame-3.98.tar.gz
		${SRC_HB}libass-0.9.9.tar.bz2
		${SRC_HB}libbluray-0.0.1-pre-213-ga869da8.tar.gz
		${SRC_HB}libdca-r81-strapped.tar.gz
		${SRC_HB}libdvdnav-svn1168.tar.gz
		${SRC_HB}libdvdread-svn1168.tar.gz
		${SRC_HB}libmkv-0.6.4.1-3-g62ce8b9.tar.gz
		${SRC_HB}libogg-1.1.3.tar.gz
		${SRC_HB}libsamplerate-0.1.4.tar.gz
		${SRC_HB}libtheora-1.1.0.tar.bz2
		${SRC_HB}libvorbis-aotuv_b5.tar.gz
		${SRC_HB}libxml2-2.7.7.tar.gz
		${SRC_HB}mp4v2-trunk-r355.tar.bz2
		${SRC_HB}mpeg2dec-0.5.1.tar.gz
		${SRC_HB}x264-r1995-c1e60b9.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+css gtk"
RDEPEND="sys-libs/zlib
	css? ( media-libs/libdvdcss )
	gtk? (	x11-libs/gtk+:2
			dev-libs/dbus-glib
			net-libs/webkit-gtk
			x11-libs/libnotify
			media-libs/gstreamer
			media-libs/gst-plugins-base
	)"
DEPEND="sys-devel/automake:1.4
	sys-devel/automake:1.9
	sys-devel/automake:1.10
	dev-lang/yasm
	dev-lang/python
	|| ( net-misc/wget net-misc/curl ) 
	${RDEPEND}"

# Handbrake attempts to download tarballs itself in its build system,
# so copy them to the expected location instead.
src_prepare() {
	mkdir "${S}"/download
	for x in ${A}; do
		cp "${DISTDIR}"/${x} "${S}"/download/ || die "copying failed"
	done
	cp "${DISTDIR}"/a52dec-0.7.4-${P}.tar.gz \
		"${S}"/download/a52dec-0.7.4.tar.gz || die "copying died"
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
	WANT_AUTOMAKE=1.9 emake -C build || die "failed compiling ${PN}"
}

src_install() {
	emake -C build DESTDIR="${D}" install || die "failed installing ${PN}"
	emake -C build doc
	dodoc AUTHORS CREDITS NEWS THANKS
	dodoc build/doc/articles/txt/*
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
