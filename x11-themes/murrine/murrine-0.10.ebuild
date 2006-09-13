# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Murrine GTK+2 Cairo Engine"
HOMEPAGE="http://www.gnome-look.org/content/show.php?content=42755"
SRC_URI="http://cimi.netsons.org/media/download_gallery/murrine/murrine-0.10.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.6"

S=${WORKDIR}/murrine-0.10/

src_compile() {
	econf --enable-animation || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}

