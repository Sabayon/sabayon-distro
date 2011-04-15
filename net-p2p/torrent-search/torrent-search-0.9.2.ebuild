# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2:2.6"

inherit python

DESCRIPTION="A torrent searching application"
HOMEPAGE="http://torrent-search.sourceforge.net/"
SRC_URI="mirror://sourceforge/torrent-search/${PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gnome"

DEPEND=""
RDEPEND=">=dev-python/httplib2-0.6.0
	>=sys-devel/gettext-0.17
	>=dev-python/pygtk-2.12
	>=dev-python/dbus-python-0.83
	>=dev-libs/libxml2-2.7.6[python]
	gnome? ( dev-python/gnome-applets-python )"
S="${WORKDIR}/${PN}"

src_compile() {
	python2 setup.py build || die "build failed"
}

src_install() {
	python2 setup.py install \
		--root="${D}" \
		--prefix="${EPREFIX}/usr" \
		|| die "src_install failed"

	if ! use gnome; then
		rm -f "${ED}"usr/bin/torrent-search-gnomeapplet
		rm -f "${ED}"usr/lib/bonobo/servers/TorrentSearch_Applet.server
	fi
}
