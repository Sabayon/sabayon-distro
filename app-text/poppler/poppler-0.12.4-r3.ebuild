# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/poppler-0.12.4-r3.ebuild,v 1.1 2010/04/25 17:37:03 the_paya Exp $

EAPI="2"

inherit base eutils autotools

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz
	http://distfiles.sabayon.org/${CATEGORY}/poppler-patches-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+abiword cairo cjk debug doc exceptions jpeg jpeg2k +lcms png qt4 +utils +xpdf-headers"

COMMON_DEPEND=">=media-libs/fontconfig-2.6.0
	>=media-libs/freetype-2.3.9
	sys-libs/zlib
	abiword? ( dev-libs/libxml2:2 )
	cairo? ( ~app-text/poppler-glib-${PV}[cairo] )
	jpeg? ( >=media-libs/jpeg-7:0 )
	jpeg2k? ( media-libs/openjpeg )
	lcms? ( media-libs/lcms )
	png? ( media-libs/libpng )
	qt4? ( ~app-text/poppler-qt4-${PV} )"
DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig"
RDEPEND="${COMMON_DEPEND}
	!dev-libs/poppler
	!<app-text/poppler-qt4-${PV}
	!<app-text/poppler-glib-${PV}
	cjk? ( >=app-text/poppler-data-0.2.1 )"

DOCS="AUTHORS ChangeLog NEWS README README-XPDF TODO"
PATCHES=(
	"${WORKDIR}"/poppler-0.12.3-cmake-disable-tests.patch
	"${WORKDIR}"/poppler-0.12.3-fix-headers-installation.patch
	"${WORKDIR}"/poppler-0.12.3-gdk.patch
	"${WORKDIR}"/poppler-0.12.3-darwin-gtk-link.patch
	"${WORKDIR}"/poppler-${PV}-config.patch
	"${WORKDIR}"/poppler-0.12.3-cairo-downscale.patch
	"${WORKDIR}"/poppler-0.12.3-preserve-cflags.patch
	"${WORKDIR}"/poppler-0.12.4-nanosleep-rt.patch
	"${WORKDIR}"/poppler-0.12.4-strings_h.patch
	"${WORKDIR}"/poppler-0.12.4-xopen_source.patch
)

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
		$(use_enable xpdf-headers) \
		$(use_enable jpeg libjpeg) \
		$(use_enable jpeg2k libopenjpeg) \
		$(use_enable png libpng) \
		$(use_enable abiword abiword-output) \
		$(use_enable utils) \
		$(use_enable exceptions) || die "econf failed"
}

pkg_postinst() {
	ewarn 'After upgrading app-text/poppler you may need to reinstall packages'
	ewarn 'depending on it. If you have gentoolkit installed, you can find those'
	ewarn 'with `equery d poppler`.'
}
