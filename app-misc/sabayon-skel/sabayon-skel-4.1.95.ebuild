# Copyright 1999-2009 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils fdo-mime

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-${PVR}.tar.lzma"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="
	!<=app-misc/sabayonlinux-skel-3.5-r6
	>=x11-misc/xdg-utils-1.0.2-r3"

src_install () {
	cd ${WORKDIR}
	dodir /etc
	cp ${WORKDIR}/skel ${D}/etc -Ra

	# Sabayon Menu
	dodir /usr/share/desktop-directories
	cp ${FILESDIR}/4.0.97/xdg/*.directory ${D}/usr/share/desktop-directories/
	dodir /usr/share/sabayon
	cp -a ${FILESDIR}/4.0.97/* ${D}/usr/share/sabayon/
	doicon ${FILESDIR}/4.0.97/img/sabayon-weblink.png

    chown root:root ${D}/etc/skel -R

}

pkg_postinst () {
    #Manual install otherwise it wont be set up correctly
    xdg-desktop-menu install /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop

    fdo-mime_desktop_database_update
    ewarn "Please bugs report to bugs.sabayonlinux.org"
    ewarn "for Thev00d00's attention"
}


pkg_prerm() {
	xdg-desktop-menu uninstall /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop
}
