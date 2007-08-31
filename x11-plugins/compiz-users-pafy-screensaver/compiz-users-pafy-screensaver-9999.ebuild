# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_PN="${PN/compiz-users-pafy-}"

inherit git flag-o-matic autotools

EGIT_REPO_URI="git://anongit.opencompositing.org/users/pafy/${MY_PN}"

DESCRIPTION="Compiz Fusion Window Decorator Screensaver Plugin (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="~x11-wm/compiz-${PV}
	~x11-libs/compiz-bcop-${PV}"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	>=dev-util/intltool-0.35"

S="${WORKDIR}/${MY_PN}"

src_compile() {
	filter-ldflags -znow -z,now
	filter-ldflags -Wl,-znow -Wl,-z,now

	sed -i 's/gen-schemas .*/gen-schemas :=/' Makefile
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}/usr/lib/compiz" XMLDIR="${D}/usr/share/compiz" install || die "make install failed"
}

pkg_postinst() {
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to http://forums.gentoo-xeffects.org"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
