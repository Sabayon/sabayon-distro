# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/compiz/compiz-0.5.0.ebuild,v 1.1 2007/04/24 01:51:02 hanno Exp $

inherit autotools git

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/app/compiz"

DESCRIPTION="3D composite- and windowmanager"
HOMEPAGE="http://www.compiz.org/"
SRC_URI=""

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS=""
IUSE="dbus gnome kde svg fuse gtk"

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
	gnome? ( gnome-base/gconf
		>=x11-libs/libwnck-2.16.1
		>=gnome-base/control-center-2.16.1 )
	svg? ( gnome-base/librsvg )
	dbus? ( >=sys-apps/dbus-1.0 )
	kde? (
		|| ( kde-base/kwin kde-base/kdebase )
		dev-libs/dbus-qt3-old )
	fuse? ( sys-fs/fuse )"

RDEPEND="${DEPEND}
	x11-apps/mesa-progs"

pkg_setup() {
	if ! use gtk && use gnome ; then
		eerror "USE=\"gnome\" requires USE=\"gtk\""
		eerror "Please build with USE=\"gnome gtk\""
		die "Build with USE=\"gnome gtk\""
	fi
}

src_compile() {
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-no-gconf.patch

	eautoreconf || die "eautoreconf failed"
	intltoolize --copy --force || die "intltoolize failed"
	glib-gettextize --copy --force || die "glib-gettextize failed"

	# Temporarily removed $(use_enable gnome)
	# It breaks building

	econf \
		--with-default-plugins \
		$(use_enable gtk) \
		$(use_enable gnome gconf) \
		--disable-gnome \
		$(use_enable gnome metacity) \
		$(use_enable kde) \
		$(use_enable svg librsvg) \
		$(use_enable dbus) \
		$(use_enable dbus dbus-glib) \
		$(use_enable fuse) || die

	make || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dobin "${FILESDIR}/compiz-start" || die "dobin failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
}
