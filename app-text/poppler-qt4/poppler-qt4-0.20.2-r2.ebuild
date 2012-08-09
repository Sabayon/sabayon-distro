# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit base eutils libtool multilib autotools

DESCRIPTION="Qt4 bindings for poppler"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/poppler-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
S="${WORKDIR}/poppler-${PV}"

COMMON_DEPEND="x11-libs/qt-core:4
	x11-libs/qt-gui:4"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	x11-libs/qt-test"

PATCHES=(
	"${FILESDIR}/${PN/-qt4}-0.20.1-lcms-automagic.patch"
	"${FILESDIR}/${PN/-qt4}-0.20.2-xyscale.patch"
)

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	econf \
		--disable-poppler-glib \
		--enable-zlib \
		--enable-splash-output \
		--disable-gtk-test \
		--enable-poppler-qt4 \
		--disable-xpdf-headers \
		--disable-libjpeg \
		--disable-libopenjpeg \
		--disable-libpng \
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
