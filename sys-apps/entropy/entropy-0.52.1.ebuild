# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=1
inherit eutils subversion multilib
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/tags/${PV}"

DESCRIPTION="Official Sabayon Linux Package Manager library"
HOMEPAGE="http://www.sabayonlinux.org"
REPO_CONFPATH="/etc/entropy/repositories.conf"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="
	sys-apps/sandbox
	sys-devel/gettext
	sys-apps/diffutils
	>=dev-lang/python-2.5[sqlite]
	dev-db/sqlite[soundex]"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup entropy || die "failed to create entropy group"
}

src_unpack() {
	# prepare entropy stuff
	subversion_src_unpack
	# setting svn revision
	#cd ${ESVN_STORE_DIR}/${PN}/trunk
	#SVNREV=$(svnversion)
	echo "${PV}" > ${S}/libraries/revision
}

src_compile() {
	cd "${S}/misc/po"
	emake
}

src_install() {

	##########
	#
	# Entropy
	#
	#########

	dodir /usr/$(get_libdir)/entropy/libraries
	dodir /usr/sbin
	
	# copying libraries
	cd ${S}/libraries
	insinto /usr/$(get_libdir)/entropy/libraries
	doins *.py
	doins revision

	# copy entropy (client) server
	cd ${S}/server
	exeinto /usr/sbin/
	doexe entropy-system-daemon
	cd ${S}/libraries
	exeinto /usr/sbin
	doexe entropy.sh

	# copy configuration
	cd ${S}/conf
	dodir /etc/entropy
	insinto /etc/entropy
	doins -r *
	rm ${D}/etc/entropy/equo.conf
	rm ${D}/etc/entropy/reagent.conf
	rm ${D}/etc/entropy/activator.conf
	rm ${D}/etc/entropy/server.conf.example

	doenvd ${S}/misc/05entropy.envd

	# install localization
	cd "${S}/misc/po"
	emake DESTDIR="${D}" install

}

pkg_preinst() {
	# backup user repositories.conf
	if [ -f "${REPO_CONFPATH}" ]; then
		cp -p "${REPO_CONFPATH}" "${REPO_CONFPATH}.backup"
	fi
}

pkg_postinst() {
	# Copy config file over
	if [ -f "${REPO_CONFPATH}.backup" ]; then
		cp ${REPO_CONFPATH}.backup ${REPO_CONFPATH} -p
	else
		if [ -f "${REPO_CONFPATH}.example" ] && [ ! -f "${REPO_CONFPATH}" ]; then
			cp ${REPO_CONFPATH}.example ${REPO_CONFPATH} -p
		fi
	fi
}
