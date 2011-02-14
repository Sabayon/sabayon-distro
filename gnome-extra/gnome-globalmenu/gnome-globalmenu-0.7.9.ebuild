# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit gnome2

DESCRIPTION="Global menubar applet for GNOME/XFCE"
HOMEPAGE="http://code.google.com/p/gnome2-globalmenu/"
SRC_URI="http://gnome2-globalmenu.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome xfce"

RDEPEND="dev-libs/glib:2
	gnome-base/gconf:2
	gnome-base/gnome-menus
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libwnck
	gnome? (
		gnome-base/gnome-panel
		x11-libs/libnotify )
	xfce? ( xfce-base/xfce4-panel )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig"

RESTRICT=test

pkg_setup() {
	# gir is not in gx86, and it doesn't affect typical use
	# the tests are broken (they do not compile)
	G2CONF="${G2CONF}
		--docdir=/usr/share/doc/${PF}
		--without-gir
		--disable-tests
		$(use_with gnome gnome-panel)
		$(use_with xfce xfce4-panel)"
}

src_install() {
	gnome2_src_install

	# If 'gnome' is the only used flag, then we assume we're facing a happy
	# GNOME user and we print only the instructions on how to enable the GTK+
	# module from within GNOME Applet. Otherwise, we install an env.d file
	# enabling the module by default.
	if use xfce || ! use gnome; then
		doenvd "${FILESDIR}"/50gnome-globalmenu || die
	fi
}

pkg_postinst() {
	if use xfce || ! use gnome; then
		elog "The globalmenu GTK+ module will be enabled through the following file:"
		elog "	/etc/env.d/50gnome-globalmenu"

		if use xfce; then
			elog
			elog "Please notice that due to an upstream bug, xfce4 plugin does not hide"
			elog "the application menu bar by default. The suggested workaround is"
			elog "to run the following command when session is started:"
			elog "	globalmenu-settings show-local-menu FALSE"
			elog "( http://code.google.com/p/gnome2-globalmenu/issues/detail?id=555 )"
		fi
	elif use gnome; then
		elog "You can enable the globalmenu GTK+ through the Applet preferences"
		elog "window."
	fi
}
