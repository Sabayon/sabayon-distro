# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

WANT_AUTOMAKE="latest"
WANT_AUTOCONF="latest"

inherit eutils subversion

ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/${PN}/trunk"

DESCRIPTION="Acceleration Manager for AIGLX/XGL on SabayonLinux"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-*"
IUSE=""

S="${WORKDIR}/trunk"

DEPEND=">=x11-base/xorg-x11-7.1
        >=x11-libs/qt-4.1.4-r2
        || ( >=kde-base/kdesu-3.5.0 >=kde-base/kdebase-3.5.0 )
	x11-misc/desktop-acceleration-helpers"

src_compile () {
	ewarn "This is SVN release!"
	cd ${S}
	addwrite "${QTDIR}/etc/settings"
	qmake -project ./
	mv trunk.pro accel-manager.pro
	qmake accel-manager.pro
	emake
}

src_install () {
	cd ${S}
	exeinto /usr/bin
	doexe ${S}/accel-manager
	doexe ${S}/gltest.py

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