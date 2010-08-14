# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils python

DESCRIPTION="Official Sabayon Linux Package Manager Server Interface (tagged release)"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="http://distfiles.sabayon.org/sys-apps/entropy-${PV}.tar.bz2"
RESTRICT="mirror"
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

