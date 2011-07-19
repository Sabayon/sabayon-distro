# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
inherit eutils python

DESCRIPTION="Entropy Package Manager server-side tools"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SRC_URI="mirror://sabayon/sys-apps/entropy-${PV}.tar.bz2"

S="${WORKDIR}/entropy-${PV}"

DEPEND="~sys-apps/entropy-${PV}"
RDEPEND="${DEPEND}"

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" entropy-server-install || die "make install failed"
}

pkg_postinst() {
	python_mod_optimize "/usr/$(get_libdir)/entropy/server"
}

pkg_postrm() {
	python_mod_cleanup "/usr/$(get_libdir)/entropy/server"
}
