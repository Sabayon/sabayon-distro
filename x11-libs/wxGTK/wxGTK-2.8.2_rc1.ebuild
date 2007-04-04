# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/wxGTK/wxGTK-2.6.3.3.ebuild,v 1.3 2006/11/23 16:48:09 yvasilev Exp $

inherit eutils multilib toolchain-funcs gnuconfig versionator flag-o-matic

DESCRIPTION="GTK+ version of wxWidgets, a cross-platform C++ GUI toolkit and
wxbase non-gui library"

SRC_URI="http://ftp.wxwidgets.org/pub/2.8.2-rc1/wxGTK-${PV/_/-}.tar.bz2
	doc? ( http://ftp.wxwidgets.org/pub/2.8.2-rc1/wxWidgets-${PV/_/-}-HTML.tar.gz )"

RESTRICT="nomirror"

SLOT="2.6"
KEYWORDS="~alpha ~amd64 arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="doc gnome joystick odbc opengl sdl unicode X"
LICENSE="wxWinLL-3"
HOMEPAGE="http://www.wxwidgets.org"

# Note 1: Gettext is not runtime dependency even if nls? because wxWidgets
#         has its own implementation of it
# Note 2: PCX support is enabled if the correct libraries are detected.
#         There is no USE flag for this.

RDEPEND="X? ( opengl? ( virtual/opengl )
		>=x11-libs/gtk+-2.10
		>=dev-libs/glib-2.0
		media-libs/tiff
		x11-libs/libXinerama
		x11-libs/libXxf86vm
		gnome? ( >=gnome-base/libgnomeprintui-2.8 ) )
	odbc? ( dev-db/unixODBC )
	x86? ( sdl? ( >=media-libs/libsdl-1.2 ) )
	amd64? ( sdl? ( >=media-libs/libsdl-1.2 ) )
	ppc? ( sdl? ( >=media-libs/libsdl-1.2 ) )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	X? (
		x11-proto/xproto
		x11-proto/xineramaproto
		x11-proto/xf86vidmodeproto
	   )"

S=${WORKDIR}/wxGTK-${PV/_/-}
HTML_S=${WORKDIR}/wxWidgets-${PV/_/-}

# Configure a build.
# It takes three parameters;
# $1: prefix for the build directory (used for wxGTK which has two
#     builds needed.
# $2: "unicode" if it must be build with else ""
# $3: all the extra parameters to pass to configure script
configure_build() {
	export LANG='C'

	mkdir ${S}/$1_build
	cd ${S}/$1_build
	# odbc works with ansi only:
	subconfigure $3 $(use_with odbc)
	emake CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "emake failed"
	#wxbase has no contrib:
	if [[ -e contrib/src ]]; then
		cd contrib/src
		emake CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "emake contrib failed"
	fi

	if [[ "$2" == "unicode" ]] && use unicode; then
		mkdir ${S}/$1_build_unicode
		cd ${S}/$1_build_unicode
		subconfigure $3 --enable-unicode
		emake CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "Unicode emake failed"
		if [[ -e contrib/src ]]; then
			cd contrib/src
			emake CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "Unicode emake contrib failed"
		fi
	fi
}

# This is a commodity function which calls configure script
# with the default parameters plus extra parameters. It's used
# as building the unicode version required redoing it.
# It takes all the params and passes them to the script
subconfigure() {
	ECONF_SOURCE="${S}" \
		econf \
			--with-zlib \
			$(use_enable debug) $(use_enable debug debug_gdb) \
			$* || die "./configure failed"
}

# Installs a build
# It takes only a parameter: the prefix for the build directory
# see configure_build function
install_build() {
	cd ${S}/$1_build
	einstall libdir="${D}/usr/$(get_libdir)" || die "Install failed"
	if [[ -e contrib ]]; then
		cd contrib/src
		einstall libdir="${D}/usr/$(get_libdir)" || die "Install contrib failed"
	fi
	if [[ -e ${S}/$1_build_unicode ]]; then
		cd ${S}/$1_build_unicode
		einstall libdir="${D}/usr/$(get_libdir)" || die "Unicode install failed"
		cd contrib/src
		einstall libdir="${D}/usr/$(get_libdir)" || die "Unicode install contrib failed"
	fi
}


pkg_setup() {
	if use X; then
		einfo "To install only wxbase (non-gui libs) use USE=-X"
	else
		einfo "To install GUI libraries, in addition to wxbase, use USE=X"
	fi
}

src_compile() {
	gnuconfig_update
	append-flags -fno-strict-aliasing
	myconf="${myconf}
		$(use_with sdl)
		$(use_enable joystick)"

	if use X; then
		myconf="${myconf}
			$(use_enable opengl)
			$(use_with opengl)
			$(use_with gnome gnomeprint)"
	fi

	use X && configure_build gtk2 unicode "${myconf} --with-gtk=2"
	use X || configure_build base unicode "${myconf} --disable-gui"
}

src_install() {
	use X && install_build gtk2
	use X || install_build base

	cp ${D}/usr/bin/wx-config ${D}/usr/bin/wx-config-2.6 || die "Failed to cp wx-config"

	# In 2.6 all wx-config*'s go in/usr/lib/wx/config
	# Only install wx-config if 2.4 is not installed:
	if [ -e "/usr/bin/wx-config" ]; then
		if [ "$(/usr/bin/wx-config --release)" = "2.4" ]; then
			rm ${D}/usr/bin/wx-config
		fi
	fi

	dodoc ${S}/docs/changes.txt
	dodoc ${S}/docs/gtk/readme.txt

	if use doc; then
		dohtml -r ${HTML_S}/docs/html/*
	fi
}

pkg_postinst() {
	einfo "dev-libs/wxbase has been removed from portage."
	einfo "wxBase is installed with wxGTK, as one of many libraries."
	einfo "If only wxBase is wanted, -X USE flag may be specified."
}
