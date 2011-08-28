# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-simulation/fgrun/fgrun-1.5.2.ebuild,v 1.4 2011/03/20 20:16:57 jlec Exp $

EAPI=2
inherit autotools eutils multilib games

DESCRIPTION="A graphical frontend for the FlightGear Flight Simulator"
HOMEPAGE="http://sourceforge.net/projects/fgrun"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-games/simgear-2
	x11-libs/fltk:1[opengl,threads]"
RDEPEND="${DEPEND}
	>=games-simulation/flightgear-2"

src_prepare() {
	epatch "${FILESDIR}/${P}"-fltk.patch
	epatch "${FILESDIR}/${P}"-compile-std-string.patch
	AT_M4DIR=. eautoreconf
}

src_configure() {
	egamesconf \
		--with-plib-libraries=/usr/$(get_libdir) \
		--with-plib-includes=/usr/include
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS
	prepgamesdirs
}
