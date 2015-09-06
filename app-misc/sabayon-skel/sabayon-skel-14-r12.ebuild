# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils git-2 fdo-mime

EGIT_COMMIT="${PVR}"
EGIT_REPO_URI="git://github.com/Sabayon/skel.git"

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
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
