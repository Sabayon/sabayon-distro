# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit libtool multilib

DESCRIPTION="Library for manipulation of TIFF (Tag Image File Format) images (compatibility package)"
HOMEPAGE="http://www.remotesensing.org/libtiff/"
SRC_URI="ftp://ftp.remotesensing.org/pub/libtiff/${P}.tar.gz"

LICENSE="as-is"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+cxx jbig jpeg static-libs zlib"

DEPEND="jpeg? ( virtual/jpeg )
	jbig? ( media-libs/jbigkit )
	zlib? ( sys-libs/zlib )
	!<media-libs/tiff-3.9.4-r1"
RDEPEND="${DEPEND}
	>=media-libs/tiff-4.0"

src_prepare() {
	elibtoolize
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable cxx) \
		$(use_enable zlib) \
		$(use_enable jpeg) \
		$(use_enable jbig) \
		--without-x \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	emake DESTDIR="${D}" install || die
	# drop unseless stuff for a compat lib
	rm "${D}"/usr/bin -rf || die
	rm "${D}"/usr/share -rf || die
	rm "${D}"/usr/$(get_libdir)/libtiff.{a,la,so} -rf || die
	rm "${D}"/usr/$(get_libdir)/libtiffxx.{a,la,so} -rf || die
	dodir /usr/include/tiff3
	mv "${D}"/usr/include/*.h* "${D}"/usr/include/tiff3/ || die9
}

pkg_postinst() {
	if use jbig; then
		echo
		elog "JBIG support is intended for Hylafax fax compression, so we"
		elog "really need more feedback in other areas (most testing has"
		elog "been done with fax).  Be sure to recompile anything linked"
		elog "against tiff if you rebuild it with jbig support."
		echo
	fi
	elog "This is a compatibility package providing old libtiff-3 libraries"
	echo
}
