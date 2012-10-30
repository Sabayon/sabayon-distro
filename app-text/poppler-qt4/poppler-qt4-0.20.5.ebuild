# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/poppler-0.20.5.ebuild,v 1.1 2012/10/11 18:38:29 reavertm Exp $

EAPI=4

inherit base eutils libtool multilib autotools

DESCRIPTION="Qt4 bindings for poppler"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/poppler-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE=""
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
		x11-libs/qt-core:4
		x11-libs/qt-gui:4
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}"

PATCHES=(
	"${FILESDIR}/${PN/-qt4}-0.20.1-lcms-automagic.patch")

DOCS=(AUTHORS ChangeLog NEWS README README-XPDF TODO)

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

pkg_postinst() {
	ewarn "After upgrading app-text/poppler you may need to reinstall packages"
	ewarn "linking to it. If you're not a portage-2.2_rc user, you're advised"
	ewarn "to run revdep-rebuild"
}
