# Copyright 2004-2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion

DESCRIPTION="Seom media package"
HOMEPAGE=""
ESVN_REPO_URI="svn://dbservice.com/big/svn/${PN}/trunk"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""

src_unpack() {
        subversion_src_unpack
}

src_compile() {

	cd ${S}

	./configure --prefix=/usr || die "configure failed"
	make || die "make failed"
}

src_install() {
	cd ${S}
	make install || die "make install failed"
}
