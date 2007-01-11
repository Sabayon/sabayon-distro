# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Acceleration Manager for AIGLX/XGL on SabayonLinux"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://sabayonlinux.org/distfiles/kde-misc/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-base/xorg-x11-7.1
        >=x11-libs/qt-4.1.4-r2
        || ( >=kde-base/kdesu-3.5.0 >=kde-base/kdebase-3.5.0 )
	x11-misc/desktop-acceleration-helpers"

src_compile () {
	cd ${S}
	addwrite "${QTDIR}/etc/settings"
	qmake ${PN}.pro
	emake
}

src_install () {
	cd ${S}
	exeinto /usr/bin
	doexe ${S}/accel-manager

	if [ ! -e "/usr/share/accel-manager" ]; then
           dodir /usr/share/accel-manager
        fi

	insinto /usr/share/accel-manager
        doins ${S}/pics/icon.png
        doins ${S}/pics/accelicon.png

        insinto /usr/share/pixmaps
        doins ${S}/pics/accel-manager.png

        insinto /usr/share/applications
        doins ${S}/pics/accel-manager.desktop
}

pkg_postinst() {
        einfo "Please report all bugs to http://bugs.sabayonlinux.org"
}