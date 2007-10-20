# Copyright 2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion

DESCRIPTION="Sabayon Linux tool to configure networks using Network Manager"
HOMEPAGE="http://www.sabayonlinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"
IUSE=""
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/${PN}/trunk"

RDEPEND=">=dev-python/PyQt4-4.1"

DEPEND="${RDEPEND}"

src_unpack() {
        subversion_src_unpack
}

src_compile () {
        einfo "nothing to compile"
}


src_install () {
	cd ${S}
	dodir /usr/share/networksettings
	insinto /usr/share/networksettings
	doins -r ${S}/*

	exeinto /usr/bin
	doexe ${S}/networksettings

	insinto /usr/share/pixmaps
	doins ${S}/pixmaps/networksettings.png

	insinto /usr/share/applications
	doins ${S}/networksettings.desktop

	

}
