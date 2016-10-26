# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils fdo-mime
MY_AUTHOR="Sabayon"
MY_PN="skel"
if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/${MY_AUTHOR}/${MY_PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${MY_AUTHOR}/${MY_PN}/archive/${PVR}.tar.gz -> ${PN}-${PVR}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
	S="${WORKDIR}/${MY_PN}-${PVR}"
fi
DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
IUSE=""
RDEPEND="!<=app-misc/sabayonlinux-skel-3.5-r6"

src_install () {
	dodir /etc/xdg/menus
	cp "${S}"/* "${D}"/etc/ -Ra

	# Sabayon Menu
	dodir /usr/share/desktop-directories
	cp "${FILESDIR}"/4.0.97/xdg/*.directory "${D}"/usr/share/desktop-directories/
	dodir /usr/share/sabayon
	cp -a "${FILESDIR}"/4.0.97/* "${D}"/usr/share/sabayon/
	doicon "${FILESDIR}"/4.0.97/img/sabayon-weblink.png

	chown root:root "${D}"/etc/skel -R
}

pkg_postinst () {
	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		# Manual install otherwise it wont be set up correctly
		xdg-desktop-menu install \
			/usr/share/sabayon/xdg/sabayon-sabayon.directory \
			/usr/share/sabayon/xdg/*.desktop
	fi

	fdo-mime_desktop_database_update
}


pkg_prerm() {
	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		xdg-desktop-menu uninstall /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop
	fi
}
