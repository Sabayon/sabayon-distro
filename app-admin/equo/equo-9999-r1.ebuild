# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion

ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/trunk"

DESCRIPTION="Official Sabayon Linux Package Manager Client (SVN release)"
HOMEPAGE="http://www.sabayonlinux.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="
	dev-lang/python
	"

RDEPEND="${DEPEND}
	>=dev-python/pysqlite-2.3.3
	"

src_compile() {
	einfo "Nothing to compile"	
}

src_install() {

	dodir /usr/share/entropy/libraries
	dodir /usr/share/entropy/client
	
	# copying libraries
	cd ${S}/libraries
	insinto /usr/share/entropy/libraries
	doins *.py

	# copy client
	cd ${S}/client
	insinto /usr/share/entropy/client
	doins equoTools.py
	exeinto /usr/share/entropy/client
	doins equo

	cd ${S}
	dodir /usr/bin
	echo '#!/bin/sh' > equo
	echo 'cd /usr/share/entropy/client' >> equo
	echo 'python equo "$@"' >> equo
	exeinto /usr/bin
	doexe equo

	# copy configuration
	cd ${S}/conf
	dodir /etc/entropy
	insinto /etc/entropy
	doins entropy.conf
	doins database.conf
	doins equo.conf
	doins repositories.conf
	
}
