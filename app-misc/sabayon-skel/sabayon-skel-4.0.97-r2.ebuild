# Copyright 2004-2008 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator fdo-mime

DESCRIPTION="Sabayon Linux skel tree"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.hyperfish.org/app-misc/${PN}/${PN}-${PV}.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="
	=x11-themes/sabayon-artwork-4*
	!<=app-misc/sabayonlinux-skel-3.5-r6
	"


src_install () {

	cd ${WORKDIR}
	dodir /etc
	cp ${WORKDIR}/skel ${D}/etc -Ra
	
        #Sabayon Menu 
        dodir /usr/share/desktop-directories
        cp ${FILESDIR}/${PV}/xdg/*.directory ${D}/usr/share/desktop-directories/  
        dodir /usr/share/sabayon
        cp -a ${FILESDIR}/${PV}/* ${D}/usr/share/sabayon/
        #rm ${D}/usr/share/sabayon/xdg/sabayon-sabayon.directory
        #domenu ${D}/usr/share/sabayon/xdg/*
        doicon ${FILESDIR}/${PV}/img/sabayon-weblink.png
   
   
   chown root:root ${D}/etc/skel -R
}

pkg_postinst () {
	#Manual install otherwise it wont be set up correctly
	xdg-desktop-menu install /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop

	fdo-mime_desktop_database_update
	ewarn "Please bugs report to"
	ewarn "bugs.sabayonlinux.org"
}
