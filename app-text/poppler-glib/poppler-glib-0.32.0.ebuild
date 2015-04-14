# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils libtool multilib autotools

DESCRIPTION="Glib bindings for poppler"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/poppler-${PV}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0/51"

IUSE="cairo doc +introspection"
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
	cairo? (
		dev-libs/glib:2
		>=x11-libs/cairo-1.10.0
		introspection? ( >=dev-libs/gobject-introspection-1.32.1 )
	)
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}
"

src_configure() {
	local intro=$(use introspection && echo "yes" || echo "no")
	econf \
		$(use_enable cairo cairo-output) \
		--enable-introspection="${intro}" \
		--enable-poppler-glib \
		--enable-zlib \
		--enable-splash-output \
		--disable-gtk-test \
		--disable-poppler-qt4 \
		--disable-poppler-qt5 \
		--disable-xpdf-headers \
		--disable-libjpeg \
		--enable-libopenjpeg=none \
		--disable-libpng \
		--disable-utils || die "econf failed"
}

src_install() {
	cd "${S}/glib" || die
	emake DESTDIR="${ED}" install || die "cannot install"

	# install pkg-config data
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${S}"/poppler-glib.pc
	use cairo && doins "${S}"/poppler-cairo.pc

	if use cairo && use doc; then
		# For now install gtk-doc there
		insinto /usr/share/gtk-doc/html/poppler
		doins -r "${S}"/glib/reference/html/* \
			|| die "failed to install API documentation"
	fi
}
