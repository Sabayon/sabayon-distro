# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/compiz/compiz-0.5.0.ebuild,v 1.1 2007/04/24 01:51:02 hanno Exp $

inherit autotools

DESCRIPTION="3D composite- and windowmanager"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://xorg.freedesktop.org/archive/individual/app/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS=""
IUSE="dbus fuse gnome gtk kde svg"
RESTRICT="mirror"

DEPEND=">=media-libs/mesa-6.5.1-r1
	>=media-libs/glitz-0.5.6
	>=x11-base/xorg-server-1.1.1-r1
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/libXcomposite
	x11-libs/libXinerama
	x11-proto/damageproto
	media-libs/libpng
	>=x11-libs/gtk+-2.0
	x11-libs/startup-notification
	gnome-base/gconf
	gnome? ( >=x11-libs/libwnck-2.16.1
		>=gnome-base/control-center-2.16.1 )
	svg? ( gnome-base/librsvg )
	dbus? ( >=sys-apps/dbus-1.0 )
	kde? (
		|| ( kde-base/kdebase kde-base/kwin )
		dev-libs/dbus-qt3-old )
	fuse? ( sys-fs/fuse )"

RDEPEND="${DEPEND}
	x11-apps/mesa-progs"

pkg_setup() {
	if ! built_with_use "x11-libs/libX11" "xcb" ; then
		eerror "Compiz now requires libX11 to be built with xcb."
		eerror "Please build libX11 with USE=\"xcb\""
		die "Build libX11 with USE=\"xcb\""
	fi
}

src_compile() {
	cd "${S}"

	eautoreconf || die "eautoreconf failed"
	intltoolize --copy --force || die "intltoolize failed"
	glib-gettextize --copy --force || die "glib-gettextize failed"

	econf \
		--with-default-plugins \
		$(use_enable gtk) \
		$(use_enable gnome gconf) \
		$(use_enable gnome) \
		$(use_enable gnome metacity) \
		$(use_enable kde) \
		$(use_enable svg librsvg) \
		$(use_enable dbus) \
		$(use_enable dbus dbus-glib) \
		$(use_enable fuse) || die

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dobin "${FILESDIR}/compiz-start" || die "dobin failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
}
