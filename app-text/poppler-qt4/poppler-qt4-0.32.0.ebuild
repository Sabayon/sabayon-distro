# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils libtool multilib autotools

DESCRIPTION="Qt4 bindings for poppler"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/poppler-${PV}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0/51"
IUSE=""
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
		dev-qt/qtcore:4
		dev-qt/qtgui:4
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}"

src_configure() {
	econf \
		--disable-poppler-glib \
		--enable-zlib \
		--enable-splash-output \
		--disable-gtk-test \
		--enable-poppler-qt4 \
		--disable-poppler-qt5 \
		--disable-xpdf-headers \
		--disable-libjpeg \
		--enable-libopenjpeg=none \
		--disable-libpng \
		--disable-utils || die "econf failed"
}

src_install() {
	cd "${S}/qt4" || die
	emake DESTDIR="${ED}" install || die "cannot install"

	# install pkg-config data
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${S}"/poppler-qt4.pc
}
