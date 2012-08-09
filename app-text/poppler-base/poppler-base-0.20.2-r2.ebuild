# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit base eutils libtool autotools

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P/-base}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="cairo curl +cxx debug doc jpeg jpeg2k +lcms png qt4 tiff +utils"

COMMON_DEPEND=">=media-libs/fontconfig-2.6.0
	>=media-libs/freetype-2.3.9
	sys-libs/zlib
	curl? ( net-misc/curl )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/openjpeg )
	lcms? ( =media-libs/lcms-1* )
	png? ( media-libs/libpng:0 )
	tiff? ( media-libs/tiff:0 )"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"
RDEPEND="${COMMON_DEPEND}
	!<app-text/poppler-0.12.4-r4
	!dev-libs/poppler
	!<dev-libs/poppler-qt4-${PV}
	!<dev-libs/poppler-glib-${PV}
	!<app-text/poppler-qt4-${PV}
	!<app-text/poppler-glib-${PV}"

S="${WORKDIR}/${P/-base}"

PATCHES=(
	"${FILESDIR}/${PN/-base}-0.20.1-lcms-automagic.patch"
	"${FILESDIR}/${PN/-base}-0.20.2-xyscale.patch"
)

DOCS="AUTHORS ChangeLog NEWS README README-XPDF TODO"

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	econf \
		--disable-cairo-output \
		--disable-gtk-test \
		--disable-poppler-qt4 \
		--disable-poppler-glib \
		--enable-zlib \
		--enable-splash-output \
		--enable-xpdf-headers \
		$(use_enable jpeg libjpeg) \
		$(use_enable jpeg2k libopenjpeg) \
		$(use_enable png libpng) \
		$(use_enable tiff libtiff) \
		$(use_enable curl libcurl) \
		$(use_enable cxx poppler-cpp) \
		$(use_enable utils) || die "econf failed"
}
