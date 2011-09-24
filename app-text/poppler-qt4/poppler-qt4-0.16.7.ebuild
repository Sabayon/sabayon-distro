# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit base eutils libtool multilib

DESCRIPTION="Qt4 bindings for poppler"
SRC_URI="http://poppler.freedesktop.org/poppler-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""
S="${WORKDIR}/poppler-${PV}"

COMMON_DEPEND="x11-libs/qt-core:4
	x11-libs/qt-gui:4"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}"
DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig
	x11-libs/qt-test"

src_prepare() {
	base_src_prepare
	elibtoolize
}

src_configure() {
	econf \
		--disable-poppler-glib \
		--enable-zlib \
		--disable-gtk-test \
		--enable-poppler-qt4 \
		--disable-xpdf-headers \
		--disable-libjpeg \
		--disable-libopenjpeg \
		--disable-libpng \
		--disable-abiword-output \
		--disable-utils || die "econf failed"
}

src_compile() {
	( cd "${S}" && base_src_compile ) || die "cannot run src_compile"
}

src_install() {
	( cd "${S}/qt4" && base_src_install ) || die "cannot run base_src_install"

	# install pkg-config data
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${S}"/poppler-qt4.pc
}
