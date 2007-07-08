# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git autotools

EGIT_REPO_URI="git://anongit.opencompositing.org/fusion/compizconfig/${PN}"

DESCRIPTION="Compizconfig Settings Manager (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="~dev-python/compizconfig-python-${PV}
	>=dev-python/pygtk-2.10"

S="${WORKDIR}/${PN}"

src_compile() {
	cd ${S}
	./autogen.sh || die "autogen failed"

	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to nesl247@gmail.com"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
