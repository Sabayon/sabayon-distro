# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit base eutils libtool

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P/-base}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="cairo curl cxx debug doc jpeg jpeg2k +lcms png qt4 tiff +utils +xpdf-headers"

COMMON_DEPEND=">=media-libs/fontconfig-2.6.0
	>=media-libs/freetype-2.3.9
	sys-libs/zlib
	curl? ( net-misc/curl )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/openjpeg )
	lcms? ( =media-libs/lcms-1* )
	png? ( media-libs/libpng )
	tiff? ( media-libs/tiff )"
DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig"
RDEPEND="${COMMON_DEPEND}
	!<app-text/poppler-0.12.4-r4
	!dev-libs/poppler
	!<dev-libs/poppler-qt4-${PV}
	!<dev-libs/poppler-glib-${PV}
	!<app-text/poppler-qt4-${PV}
	!<app-text/poppler-glib-${PV}"

S="${WORKDIR}/${P/-base}"

DOCS="AUTHORS ChangeLog NEWS README README-XPDF TODO"

src_prepare() {
	base_src_prepare
	elibtoolize
}

src_configure() {
	econf \
		--disable-cairo-output \
		--disable-gtk-test \
		--disable-poppler-qt4 \
		--disable-poppler-glib \
		--enable-zlib \
		$(use_enable xpdf-headers) \
		$(use_enable jpeg libjpeg) \
		$(use_enable jpeg2k libopenjpeg) \
		$(use_enable png libpng) \
		$(use_enable tiff libtiff) \
		$(use_enable curl LIBCURL) \
		$(use_enable cxx CPP) \
		$(use_enable utils) || die "econf failed"
}
