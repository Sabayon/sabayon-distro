# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-kids/tuxtype/tuxtype-1.5.16.ebuild,v 1.3 2008/07/31 19:54:14 mr_bones_ Exp $

inherit eutils games

DESCRIPTION="Typing tutorial with lots of eye-candy"
HOMEPAGE="http://alioth.debian.org/projects/tux4kids/"
SRC_URI="http://alioth.debian.org/frs/download.php/2209/tuxtype_w_fonts-${PV}.tar.gz"

LICENSE="GPL-2 OFL-1.1"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE=""

DEPEND="media-libs/libsdl
	media-libs/sdl-pango
	media-libs/sdl-mixer
	media-libs/sdl-image
	media-libs/sdl-ttf"

S=${WORKDIR}/tuxtype_w_fonts-1.5.16

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e 's:$(prefix)/share:'${GAMES_DATADIR}':g' \
		-e 's:$(prefix)/doc/$(PACKAGE):/usr/share/doc/'${PF}':g' \
		$(find -name Makefile.in) || die "fixing Makefile paths"
	sed -i \
		-e '/\.\/data/d' \
		-e 's:/usr/share:'${GAMES_DATADIR}':' \
		tuxtype/setup.c || die "fixing src paths"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	prepalldocs
	rm -f "${D}"/usr/share/doc/${PF}/{COPYING,INSTALL}*
	doicon ${PN}.ico
	make_desktop_entry ${PN} TuxTyping /usr/share/pixmaps/${PN}.ico
	prepgamesdirs
}
