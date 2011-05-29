# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/gwibber/gwibber-2.32.0.2.ebuild,v 1.2 2010/11/01 20:14:00 arfrever Exp $

EAPI="3"
PYTHON_DEPEND="2"

inherit distutils versionator

DESCRIPTION="Gwibber is an open source microblogging client for GNOME developed with Python and GTK"
HOMEPAGE="https://launchpad.net/gwibber"
SRC_URI="http://launchpad.net/gwibber/$(get_version_component_range 1-2)/$(get_version_component_range 1-3)/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-python/dbus-python-0.80.2
	>=dev-python/gconf-python-2.18.0
	>=dev-python/imaging-1.1.6
	>=dev-python/notify-python-0.1.1
	>=dev-python/pywebkitgtk-1.0.1
	>=dev-python/simplejson-1.9.1
	>=dev-python/egenix-mx-base-3.0.0
	>=dev-python/python-distutils-extra-2.15
	>=dev-python/pycurl-7.19.0
	>=dev-python/libwnck-python-2.26.0
	>=dev-python/feedparser-4.1
	>=dev-python/pyxdg-0.15
	>=dev-python/mako-0.2.4
	>=dev-db/desktopcouch-0.4.6
	>=dev-python/pygtk-2.16
	>=gnome-base/librsvg-2.22.2"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_install() {
	distutils_src_install

	insinto /usr/share/dbus-1/services
	doins com.Gwibber{.Service,Client}.service || die "Installing services failed."
	doman gwibber{,-poster}.1 || die "Man page couldn't be installed."
}
