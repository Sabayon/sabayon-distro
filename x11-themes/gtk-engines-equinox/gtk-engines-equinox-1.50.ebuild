# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

MY_PN="equinox"
ODTAG="121881"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Sleek GTK Theme engine"
HOMEPAGE="http://gnome-look.org/content/show.php?content=121881"
SRC_URI="http://gnome-look.org/CONTENT/content-files/${ODTAG}-${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/gtk+:2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure () {
	econf --enable-animation
}

src_install () {
	emake DESTDIR="${D}" install
}
