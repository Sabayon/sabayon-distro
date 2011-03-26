# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

GCONF_DEBUG="no"

inherit eutils python gnome2

DESCRIPTION="PackageKit client for the GNOME desktop"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI="http://www.packagekit.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="udev nls"

RDEPEND="
	udev? ( >=sys-fs/udev-145[extras] )
	>=app-admin/packagekit-gtk-0.5.5
	>=dev-libs/dbus-glib-0.73
	>=dev-libs/glib-2.18.0:2
	dev-libs/libunique:1
	>=gnome-base/gconf-2.22:2
	>=gnome-base/gnome-menus-2.24.1
	media-libs/fontconfig
	>=media-libs/libcanberra-0.10[gtk]
	>=sys-apps/dbus-1.1.2
	|| ( sys-power/upower >=sys-apps/devicekit-power-007 )
	>=x11-libs/gtk+-2.19.3:2
	>=x11-libs/libnotify-0.4.3"
DEPEND="${RDEPEND}
	app-text/docbook-sgml-utils
	>=app-text/gnome-doc-utils-0.3.2
	dev-libs/libxslt
	>=dev-util/intltool-0.35.0
	dev-util/pkgconfig
	sys-devel/gettext"

RESTRICT="test" # need DISPLAY

DOCS="AUTHORS MAINTAINERS NEWS README TODO"

# NOTES:
# app-text/docbook-sgml-utils required for man pages
# app-text/gnome-doc-utils and dev-libs/libxslt required for gnome help files
# gtk-doc is generating a useless file, don't need it

# UPSTREAM:
# misuse of CPPFLAGS/CXXFLAGS ?
# see if tests can forget about display (use eclass for that ?)
# intltool and gettext only with +nls

pkg_setup() {
	# localstatedir: /var for upstream /var/lib for gentoo
	# scrollkeeper and schemas-install: managed by gnome2 eclass
	# tests: not working (need DISPLAY)
	# gtk-doc: not needed (builded file is useless)
	G2CONF="
		--localstatedir=/var
		--enable-option-checking
		--disable-dependency-tracking
		--enable-libtool-lock
		--enable-compile-warnings=yes
		--enable-iso-c
		--disable-scrollkeeper
		--disable-schemas-install
		--disable-tests
		--disable-gtk-doc
		--disable-strict
		$(use_enable nls)
		$(use_enable udev gudev)"
}

src_prepare() {
	# fix pyc/pyo generation
	rm py-compile || die "rm py-compile failed"
	ln -s $(type -P true) py-compile
}

pkg_postinst() {
	python_need_rebuild
	python_mod_optimize $(python_get_sitedir)/packagekit/
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/packagekit/
}
