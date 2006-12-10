# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.2.4.ebuild,v 1.6 2006/11/21 07:40:22 opfer Exp $

inherit eutils flag-o-matic

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ~ppc-macos ~ppc64 ~s390 ~sh sparc x86 ~x86-fbsd"
IUSE="directfb doc glitz pdf png svg X"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

RDEPEND="media-libs/fontconfig
		>=media-libs/freetype-2.2.1
		media-libs/libpng
		X?	(
				||	(
						(
							x11-libs/libXrender
							x11-libs/libXext
							x11-libs/libX11
						)
						virtual/x11
					)
				virtual/xft
			)
		directfb? ( >=dev-libs/DirectFB-0.9.24 )
		glitz? ( >=media-libs/glitz-0.5.1 )
		svg? ( dev-libs/libxml2 )
		!<x11-libs/cairo-0.2"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.9
		X? ( || ( x11-proto/renderproto virtual/x11 ) )
		doc?	(
					>=dev-util/gtk-doc-1.3
					 ~app-text/docbook-xml-dtd-4.2
				)"

src_unpack() {
	unpack ${A}
	# New SPR patch
	epatch ${FILESDIR}/${P}-dont_interfere_with_newspr.patch
}

src_compile() {
	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	econf $(use_enable X xlib) $(use_enable doc gtk-doc) $(use_enable directfb) \
		  $(use_enable svg) $(use_enable pdf) \
		  $(use_enable glitz) --enable-png --enable-freetype --enable-ps \
		  || die "configure failed"

	emake || die "compile failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}

pkg_postinst() {
	echo
	ewarn "You will most likely need to run revdep-rebuild after emerging this"
	echo
}
