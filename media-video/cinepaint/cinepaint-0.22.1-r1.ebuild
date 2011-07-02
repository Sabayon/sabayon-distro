# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit eutils versionator

MY_PV=$(replace_version_separator 2 '-')
DESCRIPTION="motion picture editing tool used for painting and retouching of movies"
HOMEPAGE="http://cinepaint.sourceforge.net/"
SRC_URI="mirror://sourceforge/cinepaint/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
# KEYWORDS="~amd64 ~x86"
KEYWORDS="~x86"
IUSE="gutenprint"

S=${WORKDIR}/${PN}-${MY_PV}

RDEPEND=">=x11-libs/gtk+-2.0
	>=media-libs/libpng-1.2
	gutenprint? ( >=net-print/gutenprint-5.0.0 )
	media-libs/openexr
	>=media-libs/lcms-1.16
	media-libs/tiff
	virtual/jpeg
	x11-libs/fltk:1
	x11-libs/libXmu
	x11-libs/libXinerama
	x11-libs/libXpm"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-proto/xineramaproto"

pkg_setup() {
	if ! built_with_use x11-libs/fltk opengl ; then
		eerror "${PN} requires x11-libs/fltk to be built with opengl"
		die "Please install x11-libs/fltk with opengl useflag enabled"
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${P}-gcc43.patch"
	epatch "${FILESDIR}/${P}-multiple_parameters_named.patch"
	epatch "${FILESDIR}/${P}-implicitdecls.patch"
	epatch "${FILESDIR}/${P}-rpath.patch"
	epatch "${FILESDIR}/${P}-hotfixes.patch"
	sed -i '/-rpath/d' plug-ins/icc_examin/icc_examin/configure \
		|| die "sed failed"
}

src_configure(){
	# Filter --as-needed in LDFLAGS
	# filter-ldflags "--as-needed"

	# use empty PRINT because of:
	# Making all in cups
	# /bin/sh: line 11: cd: cups: No such file or directory
	PRINT="" econf \
		$(use_enable gutenprint print) \
		--enable-gtk2 \
		|| die "econf failed"

	# This: s/-O.\// from configure.in seems to
	# make problems when LDFLAGS variable looks for example
	# like this: -Wl,-O1,--blah
	einfo "Fixing Makefiles..."
	find "${S}" -name Makefile -exec echo fixing '{}' \; \
		-exec sed -i 's/-Wl,,/-Wl,/g' '{}' \;
	einfo "Done."
}

src_install(){
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README NEWS
	rm "${ED}"usr/lib/pkgconfig/cinepaint-gtk.pc \
		|| die "rm for a .pc file failed"
	# workaround... https://bugs.launchpad.net/getdeb.net/+bug/489737
	einfo "removing localization files (workaround)..."
	rm -rf "${ED}"usr/share/locale || die "rm failed"
}
