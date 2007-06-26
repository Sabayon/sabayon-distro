# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git autotools

EGIT_REPO_URI="git://anongit.opencompositing.org/compcomm/compiz-configuration-system/libraries/${PN}"

DESCRIPTION="Compiz Configuration System Gconf Backend (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="~x11-wm/compiz-${PV}
	~x11-libs/ccs-lib-${PV}
	>=gnome-base/gconf-2.0"

S="${WORKDIR}/${PN}"

src_compile() {
	eautoreconf || die "eautoreconf failed"

	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to http://trac.gentoo-xeffects.org"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
