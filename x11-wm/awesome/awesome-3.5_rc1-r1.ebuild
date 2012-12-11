# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
CMAKE_MIN_VERSION="2.8"
inherit cmake-utils eutils

DESCRIPTION="A dynamic floating and tiling window manager"
HOMEPAGE="http://awesome.naquadah.org/"
MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"
SRC_URI="http://awesome.naquadah.org/download/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="dbus doc elibc_FreeBSD gnome"

SABAYON_RDEPEND="x11-themes/sabayon-artwork-core"

# Sabayon bug 2736
SABAYON_CDEPEND="
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	x11-libs/xcb-util-image
"

COMMON_DEPEND="${SABAYON_CDEPEND}
	>=dev-lang/lua-5.1
	dev-libs/libev
	>=dev-libs/libxdg-basedir-1
	media-libs/imlib2[png]
	x11-libs/cairo[xcb]
	|| ( <x11-libs/libX11-1.3.99.901[xcb] >=x11-libs/libX11-1.3.99.901 )
	>=x11-libs/libxcb-1.6
	>=x11-libs/pango-1.19.3
	>=x11-libs/startup-notification-0.10_p20110426
	>=x11-libs/xcb-util-0.3.8
	dbus? ( >=sys-apps/dbus-1 )
	elibc_FreeBSD? ( dev-libs/libexecinfo )
	>=dev-lua/lgi-0.6.1"

# graphicsmagick's 'convert -channel' has no Alpha support, bug #352282
DEPEND="${COMMON_DEPEND}
	>=app-text/asciidoc-8.4.5
	app-text/xmlto
	dev-util/gperf
	virtual/pkgconfig
	media-gfx/imagemagick[png]
	>=x11-proto/xcb-proto-1.5
	>=x11-proto/xproto-7.0.15
	doc? (
		app-doc/doxygen
		dev-lua/luadoc
		media-gfx/graphviz
	)"

RDEPEND="${COMMON_DEPEND}
	${SABAYON_RDEPEND}
	|| (
		x11-misc/gxmessage
		x11-apps/xmessage
	)"

# bug #321433: Need one of these to for awsetbg.
# imagemagick provides 'display' and is further down the default list, but
# listed here for completeness.  'display' however is only usable with
# x11-apps/xwininfo also present.
RDEPEND="${RDEPEND}
	|| (
	( x11-apps/xwininfo
	  || ( media-gfx/imagemagick[X] media-gfx/graphicsmagick[imagemagick,X] )
	)
	x11-misc/habak
	media-gfx/feh
	x11-misc/hsetroot
	media-gfx/qiv
	media-gfx/xv
	x11-misc/xsri
	media-gfx/xli
	x11-apps/xsetroot
	)"

DOCS="AUTHORS BUGS PATCHES README STYLE"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Upstreamed
	#epatch \
	#	"${FILESDIR}/${PN}-3.4.2-backtrace.patch"

	# bug  #408025
	epatch "${FILESDIR}/${PN}-3.5_rc1-convert-path.patch"

	epatch "${FILESDIR}/sabayon-background.patch"
}

src_configure() {
	mycmakeargs=(
		-DPREFIX="${EPREFIX}"/usr
		-DSYSCONFDIR="${EPREFIX}"/etc
		$(cmake-utils_use_with dbus DBUS)
		)

	# The lua docs now officially require ldoc.lua and NOT luadoc
	# As the modules documentation has been updated to the Lua 5.2 style
	has_version >=dev-lang/lua-5.2 && mycmakeargs+="$(cmake-utils_use doc GENERATE_LUADOC)"

	cmake-utils_src_configure
}

src_compile() {
	local myargs="all"

	if use doc ; then
		myargs="${myargs} doc"
	fi
	cmake-utils_src_make ${myargs}
}

src_install() {
	cmake-utils_src_install

	if use doc ; then
		(
			cd "${CMAKE_BUILD_DIR}"/doc
			mv html doxygen
			dohtml -r doxygen || die
		)
	fi
	rm -rf "${ED}"/usr/share/doc/${PN} || die "Cleanup of dupe docs failed"

	exeinto /etc/X11/Sessions
	newexe "${FILESDIR}"/${PN}-session ${PN} || die

	# GNOME-based awesome
	if use gnome ; then
		# GNOME session
		insinto /usr/share/gnome-session/sessions
		doins "${FILESDIR}/${PN}-gnome.session" || die
		# Application launcher
		insinto /usr/share/applications
		doins "${FILESDIR}/${PN}-gnome.desktop" || die
		# X Session
		insinto /usr/share/xsessions/
		doins "${FILESDIR}/${PN}-gnome-xsession.desktop" || die
	fi
}
