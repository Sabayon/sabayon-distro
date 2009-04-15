# Copyright 2004-2008 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator fdo-mime

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-${PVR}.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="
	!<=app-misc/sabayonlinux-skel-3.5-r6
	>=x11-misc/xdg-utils-1.0.2-r3"

src_unpack() {
	unpack "${A}"
	cd "${WORKDIR}"
	epatch "${FILESDIR}/${P}-ksplash.patch"
}


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

	# Hotfixes by lxnay
	rm "${D}/etc/skel/.kde4.2/share/config/phonondevicesrc"
	cp "${FILESDIR}/4.0.97/plasma-appletsrc" "${D}/etc/skel/.kde4.2/share/config/plasma-appletsrc"
	sed -i '/media_automount_open/ s/true/false/' "${D}/etc/skel/.gconf/apps/nautilus/preferences/%gconf.xml"
	sed -i '/media_automount/ s/true/false/' "${D}/etc/skel/.gconf/apps/nautilus/preferences/%gconf.xml"

        chown root:root ${D}/etc/skel -R

}

pkg_postinst () {
        #Manual install otherwise it wont be set up correctly
        xdg-desktop-menu install /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop

        fdo-mime_desktop_database_update
        ewarn "Please bugs report to"
        ewarn "bugs.sabayonlinux.org"
}


pkg_prerm() {
	xdg-desktop-menu uninstall /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop
}
