# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/poppler-0.20.5.ebuild,v 1.1 2012/10/11 18:38:29 reavertm Exp $

EAPI="4"

inherit base eutils libtool autotools

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P/-base}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="cairo cjk curl cxx debug doc jpeg jpeg2k +lcms png qt4 tiff +utils"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
	>=media-libs/fontconfig-2.6.0
	>=media-libs/freetype-2.3.9
	sys-libs/zlib
	curl? ( net-misc/curl )
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/openjpeg )
	lcms? ( media-libs/lcms:2 )
	png? ( >=media-libs/libpng-1.4:0 )
	tiff? ( media-libs/tiff:0 )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	!dev-libs/poppler
	!dev-libs/poppler-glib
	!dev-libs/poppler-qt3
	!dev-libs/poppler-qt4
	!app-text/poppler-utils
	!<app-text/poppler-qt4-${PV}
	!<app-text/poppler-glib-${PV}
	cjk? ( >=app-text/poppler-data-0.4.4 )
"

S="${WORKDIR}/${P/-base}"

PATCHES=(
	"${FILESDIR}/${PN/-base}-0.20.1-lcms-automagic.patch"
)

DOCS=(AUTHORS ChangeLog NEWS README README-XPDF TODO)

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
		$(use_enable utils) \
		--enable-cms=$(use lcms && echo "lcms2" || echo "none") \
		|| die "econf failed"
}

pkg_postinst() {
	ewarn "After upgrading app-text/poppler you may need to reinstall packages"
	ewarn "linking to it. If you're not a portage-2.2_rc user, you're advised"
	ewarn "to run revdep-rebuild"
}
