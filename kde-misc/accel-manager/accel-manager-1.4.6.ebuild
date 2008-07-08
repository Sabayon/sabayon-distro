# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion qt4

DESCRIPTION="Acceleration Manager for AIGLX/XGL on SabayonLinux"
HOMEPAGE="http://www.sabayonlinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"
IUSE=""
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/${PN}/tags/${PV}"

RDEPEND="
	$(qt4_min_version 4.2)
        x11-misc/desktop-acceleration-helpers
	x11-libs/gksu
	"

DEPEND="${RDEPEND}"

src_unpack() {
        subversion_src_unpack
}

src_compile () {
        cd ${S}
        addwrite "${QTDIR}/etc/settings"
        qmake ${PN}.pro
        emake || die "make failed"
	mv accel-manager accel-manager-bin
}


src_install () {
	cd ${S}
	dodir /usr/share/accel-manager

        exeinto /usr/sbin
        doexe accel-manager-bin
	doexe utils/accel-manager

        exeinto /usr/share/accel-manager
        doexe utils/desktop-accel-selector

        exeinto /usr/share/accel-manager
        doexe utils/accel-server-handler

        exeinto /usr/share/accel-manager
        doexe utils/accel-manager-session


        insinto /usr/share/accel-manager
        doins pics/accelicon.png
	doins pics/black.png

        insinto /usr/share/pixmaps
        doins pics/accel-manager.png

        insinto /usr/share/applications
        doins utils/accel-manager.desktop

        insinto /usr/share/xsessions
        doins utils/accel-server.desktop

}
