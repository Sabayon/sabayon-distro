# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Simple DVD slideshow maker"
HOMEPAGE="http://imagination.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.12.11
	>=media-sound/sox-14.2.0"

RDEPEND="${DEPEND}
	virtual/ffmpeg"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-transitions.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS NEWS README TODO || die "dodoc failed"
	doicon icons/48x48/${PN}.png
}

