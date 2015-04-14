# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P/-base}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0/51"
IUSE="cjk curl cxx debug doc +jpeg jpeg2k +lcms png tiff +utils"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
	>=media-libs/fontconfig-2.6.0
	>=media-libs/freetype-2.3.9
	sys-libs/zlib
	curl? ( net-misc/curl )
	jpeg? ( virtual/jpeg:0 )
	jpeg2k? ( media-libs/openjpeg:0 )
	lcms? ( media-libs/lcms:2 )
	png? ( media-libs/libpng:0= )
	tiff? ( media-libs/tiff:0 )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	cjk? ( >=app-text/poppler-data-0.4.4 )
"

S="${WORKDIR}/${P/-base}"

DOCS=(AUTHORS NEWS README README-XPDF TODO)

openjpeg_option() {
	if use jpeg2k; then
		echo --enable-libopenjpeg=openjpeg1
	else
		echo --enable-libopenjpeg=none
	fi
}

src_configure() {
	econf \
		--disable-cairo-output \
		--disable-gtk-test \
		--disable-poppler-qt4 \
		--disable-poppler-qt5 \
		--disable-poppler-glib \
		--enable-introspection=no \
		--enable-zlib \
		--enable-splash-output \
		--enable-xpdf-headers \
		$(use_enable lcms cms) \
		$(use_enable jpeg libjpeg) \
		$(openjpeg_option) \
		$(use_enable png libpng) \
		$(use_enable tiff libtiff) \
		$(use_enable curl libcurl) \
		$(use_enable cxx poppler-cpp) \
		$(use_enable utils) \
		--enable-cms=$(use lcms && echo "lcms2" || echo "none") \
		|| die "econf failed"
}
