# Copyright 1999-2006 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License, v2 or later
# Maintainer: Pawel Stolowski pawel.stolowski (at) wp.pl
# $Header:$

S="${WORKDIR}"

DESCRIPTION="KleanSweep allows you to reclaim disk space by finding unneeded files."
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=28631"
LICENSE="GPL-2"
SRC_URI="http://sabayonlinux.org/distfiles/sys-apps/${PN}-${PV}.tar.bz2"
RESTRICT="nomirror"
IUSE=""
KEYWORDS="~x86 ~amd64"

DEPEND="
	>=dev-util/scons-0.96.1
	>=dev-lang/python-2.3.5-r2
	"

RDEPEND="$DEPEND"

src_compile() {
	econf || die "configure failed"
	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc README NEWS
	domenu ${S}/src/kleansweep.desktop
}
