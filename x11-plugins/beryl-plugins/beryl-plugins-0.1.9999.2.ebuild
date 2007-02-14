# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/beryl-plugins/beryl-plugins-0.1.2.ebuild,v 1.1 2006/11/15 04:03:06 tsunam Exp $

inherit flag-o-matic

DESCRIPTION="Beryl Window Decorator Plugins"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"
IUSE="dbus vidcap"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"

DEPEND="~x11-wm/beryl-core-${PV}
        >=gnome-base/librsvg-2.14.0
        dbus? ( || (  <sys-apps/dbus-0.70 >=dev-libs/dbus-glib-0.72 ) )
	"

PDEPEND="vidcap? ( ~x11-plugins/beryl-plugins-vidcap-${PV} )"


pkg_setup() {
        if ! built_with_use x11-libs/cairo glitz ; then
                einfo "Please rebuild cairo with USE=\"glitz\""
                die "x11-libs/cairo missing glitz support"
        fi
}

src_compile() {
        filter-ldflags -znow -z,now
        filter-ldflags -Wl,-znow -Wl,-z,now

        econf $(use_enable dbus) || die "econf failed"
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

