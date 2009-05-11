# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils python

EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit git

DESCRIPTION="Official Sabayon Linux Package Manager Server Interface (tagged release)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="~sys-apps/entropy-${PV}"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" LIBDIR=usr/$(get_libdir) entropy-server-install || die "make install failed"
}

pkg_postrm() {
        python_mod_cleanup ${ROOT}/usr/$(get_libdir)/entropy/server
}

