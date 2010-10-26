# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/gwibber/gwibber-2.29.92.1.ebuild,v 1.1 2010/03/15 02:40:52 neurogeek Exp $

EAPI="2"
PYTHON_DEPEND="2"

inherit eutils distutils

DESCRIPTION="Gwibber is an open source microblogging client for GNOME developed
with Python and GTK."
HOMEPAGE="https://launchpad.net/gwibber"
SRC_URI="http://launchpad.net/${PN}/2.32/2.32.0/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-lang/python[sqlite]
	>=dev-python/dbus-python-0.80.2
	>=dev-python/gconf-python-2.18.0
	dev-python/gnome-keyring-python
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
	>=dev-python/pygtk-2.16
	dev-python/oauth
	>=gnome-base/librsvg-2.22.2
	"
src_install() {
	distutils_src_install

	insinto /usr/share/dbus-1/services
	doins com.Gwibber{.Service,Client}.service || die "Installing services failed."
	doman gwibber{,-poster}.1 || die "Man page couldn't be installed."
	elog "If your twitter account does not work try re-adding it."
	elog "Facebook support is very flaky and will probably fail a lot."
	elog "It's a structural problem with Facebook's OAuth implementation"
	elog "and rate-limiting, nothing you can really fix."
}
