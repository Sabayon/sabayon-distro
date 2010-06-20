# Copyright 2004-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EGIT_COMMIT="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/molecule.git"
inherit eutils multilib python git
SRC_URI=""
DESCRIPTION="Sabayon Linux disc image builder"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="app-cdr/cdrtools
	sys-fs/squashfs-tools
	net-misc/rsync"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" \
		PREFIX="/usr" SYSCONFDIR="/etc" install \
			|| die "emake install failed"
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/molecule
}
