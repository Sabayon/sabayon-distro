# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils autotools toolchain-funcs

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P/-base}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0/43"
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

src_configure() {
	# this is needed for multilib, see bug 459394
	local ft_libdir ft_includedir
	ft_libdir="$($(tc-getPKG_CONFIG) freetype2 --variable=libdir)"
	ft_includedir="$($(tc-getPKG_CONFIG) freetype2 --variable=includedir)"
	export FREETYPE_DIR="${ft_libdir}:${ft_includedir%/include}"
	einfo "Detected FreeType at ${FREETYPE_DIR}"

	econf \
		--disable-cairo-output \
		--disable-gtk-test \
		--disable-poppler-qt4 \
		--disable-poppler-qt4 \
		--disable-poppler-glib \
		--enable-introspection=no \
		--enable-zlib \
		--enable-splash-output \
		--enable-xpdf-headers \
		$(use_enable lcms cms) \
		$(use_enable jpeg libjpeg) \
		$(use_enable jpeg2k libopenjpeg) \
		$(use_enable png libpng) \
		$(use_enable tiff libtiff) \
		$(use_enable curl libcurl) \
		$(use_enable cxx poppler-cpp) \
		$(use_enable utils) \
		--enable-cms=$(use lcms && echo "lcms2" || echo "none") \
		|| die "econf failed"
}
