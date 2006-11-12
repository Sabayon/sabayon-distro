# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_AUTOMAKE="1.9"

inherit subversion flag-o-matic autotools

ESVN_REPO_URI="svn://svn.beryl-project.org/beryl/trunk/${PN}"
ESVN_OPTIONS="--ignore-externals"

DESCRIPTION="Beryl Window Decorator Vidcap Plugin (svn)"
HOMEPAGE="http://beryl-project.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-plugins/beryl-plugins
	x11-libs/seom"

S="${WORKDIR}/${PN}"
MAKEOPTS="${MAKEOPTS} -j1"

src_compile() {
	filter-ldflags -znow -z,now
	filter-ldflags -Wl,-znow -Wl,-z,now

	emake || die "make failed"
}

src_install() {
	dodir /usr/share/beryl
	dodir /usr/lib/beryl
	make PREFIX="${D}/usr" install || die "make install failed"
}

pkg_postinst() {
	einfo "Please report all bugs to http://dev.gentoo-xeffects.org"
	einfo "Thank you on behalf of the Gentoo XEffects team"
}
