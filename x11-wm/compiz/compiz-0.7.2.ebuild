# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/compiz/compiz-0.6.2-r1.ebuild,v 1.2 2007/11/26 16:51:23 corsair Exp $

inherit gnome2 eutils

DESCRIPTION="3D composite- and windowmanager"
HOMEPAGE="http://www.compiz.org/"
RESTRICT="nomirror"
SRC_URI="http://releases.compiz-fusion.org/0.7.2/compiz/${P}.tar.gz"
LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="dbus gnome kde kde4 svg"

DEPEND=">=media-libs/mesa-6.5.1-r1
	>=media-libs/glitz-0.5.6
	>=x11-base/xorg-server-1.1.1-r1
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/libXcomposite
	x11-libs/libXinerama
	media-libs/libpng
	>=x11-libs/gtk+-2.0
	x11-libs/pango
	x11-libs/startup-notification
	x11-libs/libxcb
	gnome-base/gconf
	>=x11-libs/libwnck-2.18.3
	dev-libs/libxslt
	gnome? ( >=gnome-base/gnome-control-center-2.16.1 )
	svg? ( gnome-base/librsvg )
	dbus? ( >=sys-apps/dbus-1.0 )
	kde? (
		|| ( kde-base/kdebase:3.5 kde-base/kwin:3.5 )
		dev-libs/dbus-qt3-old )"

RDEPEND="${DEPEND}
	x11-apps/mesa-progs"

pkg_setup() {
	ewarn "If the build fails with an XGetXCBConnection error"
	ewarn "try this: eselect opengl set xorg-x11"
	ewarn "and/or read this: http://www.sabayonlinux.org/forum/viewtopic.php?f=53&t=12933"

	built_with_use libX11 xcb && \
	built_with_use cairo xcb && \
	built_with_use mesa xcb || \
	die "libX11, cairo and mesa must all be built with the xcb useflag!"
}

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/compiz-0.7.0-CVE-2007-3920.patch"
	epatch "${FILESDIR}/compiz-0.7.0-configure.patch"
	epatch "${FILESDIR}/compiz-0.7.0-compiz-core.patch"
}

src_compile() {
	econf --with-default-plugins \
		--enable-gtk \
		--enable-gconf \
		`use_enable gnome` \
		`use_enable gnome metacity` \
		`use_enable kde` \
		`use_enable kde4` \
		`use_enable svg librsvg` \
		`use_enable dbus` \
		`use_enable dbus dbus-glib` || die

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO || die
}

pkg_postinst() {
	ewarn "Dont forget to restore your opengl config if you set it to xorg-x11!"
}
