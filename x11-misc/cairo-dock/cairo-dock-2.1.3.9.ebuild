# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils versionator

MY_PN="${PN}-core"
MY_PV=$(replace_version_separator 3 '-')
MM_PV=$(get_version_component_range '1-2')
MMD_PV=$(get_version_component_range '1-3')

DESCRIPTION="Cairo-dock is a fast, responsive, Mac OS X-like dock."
HOMEPAGE="https://launchpad.net/cairo-dock-core/"
SRC_URI="http://launchpad.net/${MY_PN}/${MM_PV}/${MMD_PV}/+download/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="xcomposite"

RDEPEND="
	!gnome-extra/cairo-dock
	dev-libs/dbus-glib
	dev-libs/glib:2
	dev-libs/libxml2
	gnome-base/librsvg
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/gtkglext
	x11-libs/libXrender
	xcomposite? (
		x11-libs/libXcomposite
		x11-libs/libXinerama
		x11-libs/libXtst
	)
"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig
	sys-devel/gettext
"

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	# Ensure user CFLAGS are used
	epatch "${FILESDIR}/${PN}-safe-cflags.patch"

	# List the files in the POTFILES and remove the glob reference
	epatch "${FILESDIR}/${PN}-pot-fix.patch"

	eautoreconf
}

src_configure() {
	econf $(use_enable xcomposite xextend)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	elog "Cairo-Dock is an app that draws on a RGBA GLX visual."
	elog "Some users have noticed that if the dock is launched,"
	elog "severals qt4-based applications could crash, like skype or vlc."
	elog "If you have this problem, add the following line into your bashrc :"
	echo
	elog "alias vlc='export XLIB_SKIP_ARGB_VISUALS=1; vlc; unset XLIB_SKIP_ARGB_VISUALS'"
	elog "see http://www.qtforum.org/article/26669/qt4-mess-up-the-opengl-context.html for more details."
}
