# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils multilib python

EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit git

DESCRIPTION="Official Sabayon Linux Package Manager library"
HOMEPAGE="http://www.sabayonlinux.org"
REPO_CONFPATH="${ROOT}/etc/entropy/repositories.conf"
ENTROPY_CACHEDIR="${ROOT}/var/lib/entropy/caches"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="~sys-apps/entropy-${PV}
	dev-python/dbus-python
	dev-libs/dbus-glib
	dev-python/pygobject
"
RDEPEND="${DEPEND}"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR=usr/$(get_libdir) updates-daemon-install || die "make install failed"
}

pkg_postrm() {
        python_mod_cleanup ${ROOT}/usr/$(get_libdir)/entropy/services
}

