# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/fltk/fltk-1.1.9.ebuild,v 1.5 2009/05/05 08:25:17 ssuominen Exp $

EAPI=2
inherit eutils autotools versionator fdo-mime

DESCRIPTION="C++ user interface toolkit for X and OpenGL."
HOMEPAGE="http://www.fltk.org"
SRC_URI="mirror://easysw/${PN}/${PV}/${P}-source.tar.bz2"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
LICENSE="FLTK LGPL-2"

SLOT="$(get_version_component_range 1-2)"

IUSE="doc examples games opengl threads xft xinerama"

RDEPEND="x11-libs/libXext
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXt
	media-libs/jpeg
	media-libs/libpng
	sys-libs/zlib
	opengl? ( virtual/opengl virtual/glu )
	xinerama? ( x11-libs/libXinerama )
	xft? ( x11-libs/libXft )"

DEPEND="${RDEPEND}
	x11-proto/xextproto
	doc? ( app-text/htmldoc )
	xinerama? ( x11-proto/xineramaproto )"

INCDIR=/usr/include/fltk-${SLOT}
LIBDIR=/usr/$(get_libdir)/fltk-${SLOT}

src_prepare() {
	#epatch "${FILESDIR}"/${P}-fromdebian.patch
	epatch "${FILESDIR}"/${P}-desktop.patch
	epatch "${FILESDIR}"/${P}-as-needed.patch
	epatch "${FILESDIR}"/${P}-gcc4.4.patch
	# prevent to run twice configure (needs eautoconf), to compile tests,
	# remove forced -Os compile
	epatch "${FILESDIR}"/${P}-conf-tests.patch
	# remove forced flags from fltk-config
	sed -i \
		-e '/C\(XX\)\?FLAGS=/s:@C\(XX\)\?FLAGS@::' \
		-e '/^LDFLAGS=/d' \
		"${S}/fltk-config.in" || die
	# some fixes introduced because slotting
	sed -i \
		-e '/RANLIB/s:$(libdir)/\(.*LIBNAME)\):$(libdir)/`basename \1`:g' \
		src/Makefile || die
	# docs in proper docdir
	sed -i \
		-e "/^docdir/s:fltk:${PF}/html:" \
		makeinclude.in || die
	sed -e "s/7/$(get_version_component_range 3)/" \
		"${FILESDIR}"/FLTKConfig.cmake > CMake/FLTKConfig.cmake
	eautoconf
}

src_configure() {
	econf \
		--includedir=${INCDIR}\
		--libdir=${LIBDIR} \
		--docdir=/usr/share/doc/${PF}/html \
		--enable-largefile \
		--enable-shared \
		--enable-xdbe \
		$(use_enable opengl gl) \
		$(use_enable threads) \
		$(use_enable xft) \
		$(use_enable xinerama)
}

src_compile() {
	emake || die "emake failed"
	if use doc; then
		cd "${S}"/documentation
		emake alldocs || die "emake doc failed"
	fi
	if use games; then
		cd "${S}"/test
		emake blocks checkers sudoku || die "emake games failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	emake -C fluid \
			DESTDIR="${D}" install-linux || die "emake install fluid failed"
	if use doc; then
		emake -C documentation \
			DESTDIR="${D}" install || die "emake install doc failed"
	fi
	local apps="fluid"
	if use games; then
		emake -C test \
			DESTDIR="${D}" install-linux || die "emake install games failed"
		emake -C documentation \
			DESTDIR="${D}" install-linux || die "emake install doc games failed"
		apps="${apps} sudoku blocks checkers"
	fi
	for app in ${apps}; do
		dosym /usr/share/icons/hicolor/32x32/apps/${app}.png \
			/usr/share/pixmaps/${app}.png
	done
	dodoc CHANGES README CREDITS ANNOUNCEMENT

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins test/*.{h,cxx,fl} test/demo.menu
	fi

	insinto /usr/share/cmake/Modules
	doins CMake/FLTK*.cmake

	echo "LDPATH=${LIBDIR}" > 99fltk-${SLOT}
	echo "FLTK_DOCDIR=/usr/share/doc/${PF}/html" >> 99fltk-${SLOT}
	doenvd 99fltk-${SLOT}
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
