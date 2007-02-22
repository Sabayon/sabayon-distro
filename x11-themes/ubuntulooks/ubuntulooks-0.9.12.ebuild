# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Ubuntu GTK+2 Cairo Engine"
HOMEPAGE="http://www.gnome-look.org/content/show.php?content=43255"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/main/u/${PN}/${PN}_${PV}.orig.tar.gz"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc ~ppc64"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.10"

src_compile() {
	econf --enable-animation || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}

