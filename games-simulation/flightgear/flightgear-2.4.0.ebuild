# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils games

MY_PN=FlightGear
DESCRIPTION="Open Source Flight Simulator"
HOMEPAGE="http://www.flightgear.org/"
SRC_URI="mirror://flightgear/Source/${P}.tar.bz2
	mirror://flightgear/Shared/${MY_PN}-data-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="subversion"

RDEPEND=">=dev-games/openscenegraph-2.9[png]
	=dev-games/simgear-2.4.0[subversion=]
	media-libs/plib
	x11-libs/libXmu
	x11-libs/libXi
	subversion? ( dev-vcs/subversion )"
DEPEND="${RDEPEND}"

src_configure() {
	egamesconf \
	--without-fgpanel \
	$(use_with subversion libsvn)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS README Thanks
	insinto "${GAMES_DATADIR}"/"${PN}"
	doins -r ../data/* || die "doins failed"
	newicon ../data/Aircraft/A6M2/thumbnail.jpg ${PN}.png
	make_desktop_entry fgfs "${MY_PN}"
	prepgamesdirs
}
