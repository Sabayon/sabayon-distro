# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="2"

inherit eutils gnome2 python virtualx

DESCRIPTION="PackageKit client for the GNOME desktop"
HOMEPAGE="http://www.packagekit.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc nls test udev"

RDEPEND="
	>=app-admin/packagekit-gtk-0.5.5
	>=dev-libs/dbus-glib-0.73
	>=dev-libs/glib-2.18.0:2
	dev-libs/libunique:1
	>=gnome-base/gconf-2.22:2
	>=gnome-base/gnome-menus-2.24.1
	media-libs/fontconfig
	>=media-libs/libcanberra-0.10[gtk]
	>=sys-apps/dbus-1.1.2
	>=sys-power/upower-0.9
	>=x11-libs/gtk+-2.19.3:2
	>=x11-libs/libnotify-0.7.1
	udev? ( >=sys-fs/udev-145[extras] )"
DEPEND="${RDEPEND}
	app-text/docbook-sgml-utils
	>=app-text/gnome-doc-utils-0.3.2
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	dev-util/pkgconfig
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.9 )"

#RESTRICT="test" # need DISPLAY

# NOTES:
# app-text/docbook-sgml-utils required for man pages
# app-text/gnome-doc-utils and dev-libs/libxslt required for gnome help files
# gtk-doc is generating a useless file, don't need it

# UPSTREAM:
# misuse of CPPFLAGS/CXXFLAGS ?
# see if tests can forget about display (use eclass for that ?)
# intltool and gettext only with +nls

pkg_setup() {
	DOCS="AUTHORS MAINTAINERS NEWS README TODO"
	# localstatedir: /var for upstream /var/lib for gentoo
	# scrollkeeper and schemas-install: managed by gnome2 eclass
	# tests: not working (need DISPLAY)
	# gtk-doc: not needed (builded file is useless)
#		--enable-libtool-lock
#		--disable-dependency-tracking
#		--enable-option-checking
	G2CONF="
		--localstatedir=/var
		--enable-compile-warnings=yes
		--enable-iso-c
		--disable-scrollkeeper
		--disable-schemas-install
		--disable-strict
		$(use_enable nls)
		$(use_enable test tests)
		$(use_enable udev gudev)"
	python_set_active_version 2
}

src_prepare() {
	gnome2_src_prepare

	epatch "${FILESDIR}/${P}-libnotify-0.7.patch"

	# fix pyc/pyo generation
	rm py-compile || die "rm py-compile failed"
	ln -s $(type -P true) py-compile
}

src_test() {
	Xemake check || die "make check failed"
}

pkg_postinst() {
	gnome2_pkg_postinst
	python_need_rebuild
	python_mod_optimize packagekit
}

pkg_postrm() {
	gnome2_pkg_postrm
	python_mod_cleanup packagekit
}
