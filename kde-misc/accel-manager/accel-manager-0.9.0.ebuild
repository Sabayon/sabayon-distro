# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Acceleration Manager for AIGLX/XGL on SabayonLinux"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""

DEPEND=">=x11-base/xorg-x11-7.1
        || ( >=kde-base/kommander-3.5.0 >=kde-base/kdewebdev-3.5.0 )
        || ( >=kde-base/kdesu-3.5.0 >=kde-base/kdebase-3.5.0 )
	x11-misc/desktop-acceleration-helpers"

src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/* . -p

}

src_install () {

	cd ${WORKDIR}
	if [ ! -e "/usr/share/accel-manager" ]; then
	   dodir /usr/share/accel-manager
	fi

	exeinto /usr/sbin/
	doexe accel-manager

	exeinto /usr/share/accel-manager
	doexe desktop-accel-selector

	exeinto /usr/share/accel-manager
	doexe accel-server-handler

	exeinto /usr/share/accel-manager
	doexe accel-manager-session

	insinto /usr/share/accel-manager
	doins icon.png
	doins accelicon.png
	doins *.kmdr

	insinto /usr/share/pixmaps
	doins accel-manager.png

	insinto /usr/share/applications
	doins accel-manager.desktop

	insinto /usr/share/xsessions
	doins accel-server.desktop

}
