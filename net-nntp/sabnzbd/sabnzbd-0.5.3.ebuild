# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit distutils eutils 

MY_P="${P/sab/SAB}"

DESCRIPTION="Binary Newsgrabber written in Python, server-oriented using a web-interface.The active successor of the abandoned SABnzbd project."
HOMEPAGE="http://www.sabnzbd.org/"
SRC_URI="mirror://sourceforge/sabnzbdplus/${MY_P}-src.tar.gz"

HOMEDIR="${ROOT}var/lib/${PN}"
DHOMEDIR="/var/lib/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+rar unzip rss +yenc ssl"

RDEPEND=">=dev-lang/python-2.4.4
		>=dev-python/celementtree-1.0.5
		=dev-python/cherrypy-2*
		>=dev-python/cheetah-2.0.1
		>=app-arch/par2cmdline-0.4
		rar? ( app-arch/rar )
		unzip? ( >=app-arch/unzip-5.5.2 )
		rss? ( >=dev-python/feedparser-4.1 )
		yenc? ( >=dev-python/yenc-0.3 )
		ssl? ( dev-python/pyopenssl )"
DEPEND="${RDEPEND}
		app-text/dos2unix"

S="${WORKDIR}/${MY_P}"
DOCS="CHANGELOG.txt ISSUES.txt INSTALL.txt README.txt"

src_unpack() {
	unpack ${A}
	cp "${FILESDIR}/${PN}-gentoo-setup.py" "${S}/setup.py"
}

pkg_setup() {
	#Create group and user
	enewgroup "${PN}"
	enewuser "${PN}" -1 -1 "${HOMEDIR}" "${PN}"
}

src_install() {
	distutils_src_install

	#Init scripts
	newinitd "${FILESDIR}/${PN}.init" "${PN}"
	newconfd "${FILESDIR}/${PN}.conf" "${PN}"

	#Example config
	insinto /etc
	newins "${FILESDIR}/${PN}.ini" "${PN}.conf"
	fowners root:${PN} /etc/${PN}.conf
	fperms 660 /etc/${PN}.conf

	#Create all default dirs
	keepdir ${DHOMEDIR}

	for i in download dirscan complete nzb_backup cache scripts; do
		keepdir ${DHOMEDIR}/${i}
	done
	fowners -R ${PN}:${PN} ${DHOMEDIR}
	fperms -R 775 ${DHOMEDIR}

	keepdir /var/log/sabnzbd
	fowners -R ${PN}:${PN} /var/log/${PN}
	fperms -R 775 /var/log/${PN}

	#Add themes
	cd "${D}"
	mv usr/interfaces usr/share/${P}

	#fix permission on themes
	fowners -R root:sabnzbd /usr/share/${P}

	#create symlink to keep the initial conf version free
	dosym /usr/share/${P} /usr/share/${PN}
}

pkg_postinst() {
	distutils_pkg_postinst

	einfo "Default directory: ${HOMEDIR}"
	einfo "Templates can be found in: ${ROOT}usr/share/${P}"
	einfo ""
	einfo "Run: gpasswd -a <user> sabnzbd"
	einfo "to add an user to the sabnzbd group so it can edit sabnzbd files"
	einfo ""
	ewarn "Please configure /etc/conf.d/${PN} before starting!"
	einfo ""
	einfo "Start with ${ROOT}etc/init.d/${PN} start"
}

