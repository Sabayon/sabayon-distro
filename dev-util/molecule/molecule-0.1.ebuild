# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/molecule/tags/${PV}"

DESCRIPTION="Release metatool used for creating Sabayon releases"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="app-cdr/cdrtools
	sys-fs/squashfs-tools
	net-misc/rsync
"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "nothing to compile"
}

src_install() {


	cd "${S}"
	dodir /usr/$(get_libdir)/
	insinto /usr/$(get_libdir)/
	doins -r molecule

	dodir /usr/bin
	exeinto /usr/bin
	mkdir bin
	mv molecule.py bin/molecule
	doexe bin/molecule

}
