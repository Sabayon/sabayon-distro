# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit eutils multilib python git

DESCRIPTION="Official Sabayon Linux Package Manager Client"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="~sys-apps/entropy-${PV}"
RDEPEND="${DEPEND}"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" equo-install || die "make install failed"
}

pkg_postinst() {
	python_mod_compile "/usr/$(get_libdir)/entropy/client"
}

pkg_postrm() {
        python_mod_cleanup "/usr/$(get_libdir)/entropy/client"
}

