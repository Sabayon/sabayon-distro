# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit autotools eutils

DESCRIPTION="Astronomy simulation and visualization software"
HOMEPAGE="http://www.nightshadesoftware.org/"
SRC_URI="http://www.nightshadesoftware.org/downloads/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-libs/boost-1.42
	media-gfx/graphicsmagick
	media-libs/libpng
	>=media-libs/libsdl-1.2.10
	media-libs/sdl-mixer
	media-libs/sdl-pango
	virtual/glu
	virtual/opengl
"
DEPEND="${RDEPEND}
	dev-db/fastdb
"

src_prepare() {
	# Don't call system() with cp or mkdir.
	epatch "${FILESDIR}"/${PV}-fix-cp-mkdir.patch
	sed -i 's:/usr/local/lib/libfastdb.a:/usr/lib/libfastdb.a:' \
		configure.ac \
		|| die "sed failed"
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog HACKING README TODO TRADEMARKS \
		|| die "installing documentation files failed"
}
