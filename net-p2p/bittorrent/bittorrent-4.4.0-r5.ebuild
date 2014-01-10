# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_DEPEND="2:2.5"
PYTHON_USE_WITH="threads"

# Maintainer note:
#  keep this package at 4.4.0.
#    5.x - requires wxpython-2.6 which we don't carry
#    6.x - binary-only non-free crap
# Fedora has also frozen bittorrent at 4.4.0 and is a good source of patches
# http://pkgs.fedoraproject.org/gitweb/?p=bittorrent.git

inherit distutils eutils fdo-mime python user systemd

MY_P="${P/bittorrent/BitTorrent}"

DESCRIPTION="Tool for distributing files via a distributed network of nodes"
HOMEPAGE="http://www.bittorrent.com/"
SRC_URI="http://www.bittorrent.com/dl/${MY_P}.tar.gz"

LICENSE="BitTorrent"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND=">=dev-python/pycrypto-2.0"
DEPEND="${RDEPEND}"
#	dev-python/dnspython"

S=${WORKDIR}/${MY_P}

DOCS="README.txt TRACKERLESS.txt"
PYTHON_MODNAME="BitTorrent khashmir"

pkg_setup() {
	enewgroup bttrack
	enewuser bttrack -1 -1 /dev/null bttrack
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}"/${P}-no-version-check.patch
	epatch "${FILESDIR}"/${P}-pkidir.patch
	epatch "${FILESDIR}"/${P}-fastresume.patch
	epatch "${FILESDIR}"/${P}-pygtk-thread-warnings.patch
	epatch "${FILESDIR}"/${P}-python26-syntax.patch
	epatch "${FILESDIR}"/${P}-bencode-float.patch
	epatch "${FILESDIR}"/${P}-keyerror.patch
	epatch "${FILESDIR}"/${P}-hashlib.patch
	epatch "${FILESDIR}"/${P}-css-support.patch
	# Sabayon infrastructure requirement, make the
	# .torrent file scraping recurse through all the
	# allowed_dir subdirs
	epatch "${FILESDIR}"/${P}-sabayon-parsedir-recursive.patch

	# fix doc path #109743
	sed -i -e "/dp.*appdir/ s:appdir:'${PF}':" BitTorrent/platform.py
}

src_install() {
	distutils_src_install

	doicon images/bittorrent.ico
	domenu "${FILESDIR}"/${PN}.desktop
	# use !aqua:
	rm -f "${ED}"usr/bin/{bit,make}torrent

	insinto /etc/pki/bittorrent/
	doins public.key

	# Used by ALLOWED_DIR=
	dodir /var/www/torrents
	keepdir /var/www/torrents
	dodir /usr/share/bittorrent
	keepdir /usr/share/bittorrent
	dodir /var/log/bittorrent
	keepdir /var/log/bittorrent

	newinitd "${FILESDIR}"/bittorrent-tracker.initd bittorrent-tracker
	newconfd "${FILESDIR}"/bittorrent-tracker.confd bittorrent-tracker

	systemd_dounit "${FILESDIR}"/bittorrent-tracker.service
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update

	for dir in "/usr/share/bittorrent" "/var/www/torrents" "/var/log/bittorrent"; do
		chown -R bttrack:bttrack "${EROOT}${dir}"
	done
}

pkg_postrm() {
	distutils_pkg_postrm
	fdo-mime_desktop_database_update
}
