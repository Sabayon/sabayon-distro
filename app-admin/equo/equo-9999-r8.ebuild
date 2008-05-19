# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/trunk/"

DESCRIPTION="Official Sabayon Linux Package Manager Client (SVN release)"
HOMEPAGE="http://www.sabayonlinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="~sys-apps/entropy-9999"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "nothing to compile"
}

src_install() {

	##########
	#
	# Equo
	#
	#########

	dodir /usr/$(get_libdir)/entropy/client
	dodir /etc/portage

	# copying portage bashrc
	insinto /etc/portage
	mv ${S}/conf/etc-portage-bashrc ${S}/conf/bashrc.entropy
	doins ${S}/conf/bashrc.entropy

        # copy configuration
        cd ${S}/conf
        dodir /etc/entropy
        insinto /etc/entropy
        doins equo.conf
	# FIXME: remove this below
        doins repositories.conf
	
	# copy client
	cd ${S}/client
	insinto /usr/$(get_libdir)/entropy/client
	doins *.py
	doins entropy-system-test-client

	cd ${S}
	dodir /usr/bin
	echo '#!/bin/sh' > equo
	echo 'if [ -f "/etc/profile" ]; then source /etc/profile; fi' >> equo
	echo 'cd /usr/'$(get_libdir)'/entropy/client' >> equo
	echo 'LD_LIBRARY_PATH="/usr/'$(get_libdir)'/entropy/client/lib/:/usr/'$(get_libdir)'/entropy/client/libraries/pysqlite2/" python equo.py "$@"' >> equo
	exeinto /usr/bin
	doexe equo

}
