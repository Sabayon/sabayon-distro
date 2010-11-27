# Copyright 1999-2009 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
EGIT_COMMIT="${PVR}"
EGIT_REPO_URI="git://git.sabayon.org/projects/skel.git"
inherit eutils git fdo-mime

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayon.org"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND="!<=app-misc/sabayonlinux-skel-3.5-r6
	sys-apps/findutils"

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

	# Workaround for buggy mime dir stuff stored in $HOME, sigh!
	# >=x11-misc/shared-mime-info-0.70 breaks
	find "${ROOT}"home/*/.local/share -name "mime" -type d | xargs rm -rf

	fdo-mime_desktop_database_update
	ewarn "Please bugs report to bugs.sabayonlinux.org"
	ewarn "for Thev00d00's attention"
}


pkg_prerm() {
	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		xdg-desktop-menu uninstall /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop
	fi
}
