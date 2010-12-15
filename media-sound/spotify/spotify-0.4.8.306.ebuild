# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

MY_PN="spotify-client-qt"
MY_PV="${PV}.g1df0858"
MY_P="${MY_PN}_${MY_PV}"

DESCRIPTION="A proprietary peer-to-peer music streaming desktop application"
HOMEPAGE="http://www.spotify.com"
SRC_URI="http://repository.spotify.com/pool/non-free/s/spotify/${MY_P}-1_amd64.deb
x86?   ( http://repository.spotify.com/pool/non-free/s/spotify/${MY_P}-1_i386.deb )"

LICENSE="Spotify"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# media-sound/asoundconf left
DEPEND=""
RDEPEND="${RDEPEND}
	>=x11-libs/qt-dbus-4.5.0
	>=x11-libs/qt-webkit-4.5.0
	>=x11-libs/qt-core-4.5.0
	>=x11-libs/qt-gui-4.5.0"

src_unpack() {
	unpack ${A} ./data.tar.gz
}

src_install() {
	insinto /opt/${PN}
	into /opt/${PN}
	dobin usr/bin/spotify
	dosym /opt/${PN}/bin/spotify /usr/bin/spotify
	newdoc usr/share/doc/spotify-client-qt/changelog.Debian.gz changelog.gz
        doins -r usr/share/spotify/theme
	# hardcoded path fix
	dodir /usr/share/spotify
	dosym /opt/${PN}/theme /usr/share/spotify/theme
}
