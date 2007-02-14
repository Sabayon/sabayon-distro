# Copyright 2004-2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit flag-o-matic

DESCRIPTION="Beryl Window Decorator Unsupported Plugins"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND="~x11-plugins/beryl-plugins-${PV}"

src_compile() {
        filter-ldflags -znow -z,now
        filter-ldflags -Wl,-znow -Wl,-z,now

        econf || die "econf failed"
        emake -j1 || die "make failed"
}

src_install() {
        make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
        ewarn "DO NOT report bugs to Gentoo's bugzilla"
        einfo "Please report all bugs to http://bugs.gentoo-xeffects.org"
        einfo "Thank you on behalf of the Gentoo XEffects team"
}
