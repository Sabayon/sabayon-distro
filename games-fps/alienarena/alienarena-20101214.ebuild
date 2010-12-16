# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-fps/alienarena/alienarena-20100726.ebuild,v 1.3 2010/09/24 07:48:38 hwoarang Exp $

EAPI=2
inherit eutils games

MY_PN=alienarena-7_50
DESCRIPTION="Fast-paced multiplayer deathmatch game"
HOMEPAGE="http://red.planetarena.org/"
SRC_URI="http://icculus.org/alienarena/Files/${MY_PN}-linux${PV}.tar.gz"
RESTRICT="nomirror"

LICENSE="GPL-2 free-noncomm"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="dedicated opengl"

UIRDEPEND="media-libs/jpeg
	media-libs/openal
	media-libs/libvorbis
	virtual/glu
	virtual/opengl
	x11-libs/libXxf86dga
	x11-libs/libXxf86vm"
RDEPEND="opengl? ( ${UIRDEPEND} )
	!opengl? ( !dedicated? ( ${UIRDEPEND} ) )
	net-misc/curl"
UIDEPEND="x11-proto/xf86dgaproto
	x11-proto/xf86vidmodeproto"
DEPEND="${RDEPEND}
	opengl? ( ${UIDEPEND} )
	!opengl? ( !dedicated? ( ${UIDEPEND} ) )
	dev-util/pkgconfig
	app-arch/unzip"

S=${WORKDIR}/${PN}-7.50

src_configure() {
	local opts=""
	use dedicated && opts+="--disable-client"
	egamesconf ${opts} || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	prepgamesdirs

	if use opengl || ! use dedicated ; then
		make_desktop_entry /usr/games/bin/crx "Alien Arena" aa
		make_desktop_entry /usr/games/bin/crx-ded "Alien Arena (dedicated)" aa
	fi

	cd "${S}" || die
	newicon aa.png ${PN}.png || die "newicon failed"
	dodoc docs/README.txt
}
