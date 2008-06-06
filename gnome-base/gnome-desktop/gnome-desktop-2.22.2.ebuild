# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-desktop/gnome-desktop-2.22.2.ebuild,v 1.1 2008/05/31 12:32:13 eva Exp $

inherit gnome2 eutils

DESCRIPTION="Libraries for the gnome desktop that is not part of the UI"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/libxml2-2.4.20
		 >=x11-libs/gtk+-2.11.3
		 >=dev-libs/glib-2.15.4
		 >=gnome-base/gconf-2
		 >=gnome-base/libgnomeui-2.6
		 >=x11-libs/startup-notification-0.5"
DEPEND="${RDEPEND}
		app-text/scrollkeeper
		sys-devel/gettext
		>=dev-util/intltool-0.35
		>=dev-util/pkgconfig-0.9
		>=app-text/gnome-doc-utils-0.3.2
		doc? ( >=dev-util/gtk-doc-1.4 )
		x11-proto/xproto"
# Includes X11/Xatom.h in libgnome-desktop/gnome-bg.c which comes from xproto

DOCS="AUTHORS ChangeLog HACKING NEWS README"

src_unpack() {
	unpack ${A} || die "unpack failed"
	cd ${S}
	epatch "${FILESDIR}"/${P}-fix-wallpaper-loop.patch
}

pkg_setup() {
	G2CONF="${G2CONF} --with-gnome-distributor=Gentoo --disable-scrollkeeper"
}
