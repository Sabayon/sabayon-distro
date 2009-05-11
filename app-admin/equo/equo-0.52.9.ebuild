# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils
EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
EGIT_BRANCH="stable"
inherit git

DESCRIPTION="Official Sabayon Linux Package Manager Client"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="~sys-apps/entropy-${PV}"
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
	
	# copy client
	cd ${S}/client
	insinto /usr/$(get_libdir)/entropy/client
	doins *.py
	doins entropy-system-test-client
	exeinto /usr/$(get_libdir)/entropy/client
	doexe equo.py

	dodir /usr/bin
	dosym /usr/$(get_libdir)/entropy/client/equo.py /usr/bin/equo

}
