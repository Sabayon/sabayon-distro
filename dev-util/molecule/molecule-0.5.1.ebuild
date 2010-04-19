# Copyright 2004-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/molecule.git"
inherit eutils multilib python git
SRC_URI=""
DESCRIPTION="Release metatool used for creating Sabayon releases"
HOMEPAGE="http://www.sabayonlinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="app-cdr/cdrtools
	sys-fs/squashfs-tools
	net-misc/rsync
"

src_compile() {
	einfo "nothing to compile"
}

src_install() {


	cd "${S}"
	dodir /usr/$(get_libdir)/molecule
	insinto /usr/$(get_libdir)/molecule
	doins -r molecule

	dodir /usr/bin
	exeinto /usr/bin
	mkdir bin
	mv molecule.py bin/molecule
	doexe bin/molecule

	dodir /etc/molecule
	insinto /etc/molecule
	doins -r examples

}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/molecule
}
