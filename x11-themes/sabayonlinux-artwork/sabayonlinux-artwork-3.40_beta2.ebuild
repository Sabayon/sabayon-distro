# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# Ebuild is now versioned by release, ex. 3.25, 3.3, 3.3_pre1, etc

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official artwork, can include wallpapers, ksplash, and GTK/QT Themes."
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://www.sabayonlinux.org/distfiles/x11-themes/${PN}/${PN}-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64"
IUSE="symlink"
RESTRICT="nomirror"
DEPEND=">=x11-libs/gtk+-2.10
	x11-themes/ubuntulooks
	>=kde-misc/ksplash-engine-moodin-0.4.2
	x11-themes/evilred
	"


RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {

	if [ ! -e ${ROOT}/usr/share/backgrounds ]; then
          dodir ${ROOT}/usr/share/backgrounds
        fi

	if [ ! -e ${ROOT}/usr/share/themes ]; then
          dodir ${ROOT}/usr/share/themes
        fi

	if [ ! -e ${ROOT}/etc/splash ]; then
          dodir ${ROOT}/etc/splash
        fi

	cd ${S}/background
	insinto ${ROOT}/usr/share/backgrounds
	doins *.jpg *.png

	cd ${S}/gtk
	insinto ${ROOT}/usr/share/themes
	doins -r ./

	cd ${S}/metacity
	insinto ${ROOT}/usr/share/themes
	doins -r ./

	# GNOME splash
	cd ${S}/gnome-splash
	insinto ${ROOT}/usr/share/pixmaps/splash
	doins *.png

	if [ -e ${ROOT}/usr/kde/3.5 ]; then
	  kdedir="${ROOT}/usr/kde/3.5"
	elif [ -e ${ROOT}/usr/kde/3.4 ]; then
	  kdedir="${ROOT}/usr/kde/3.4"
	else
	  kdedir="nokde"	
	fi

	if [ "$kdedir" != "nokde" ] && [ -e "$kdedir/share/apps/ksplash/Themes" ]; then

	  cd ${S}/ksplash/Lines
	  dodir /usr/share/apps/ksplash/Themes/Lines
	  insinto /usr/share/apps/ksplash/Themes/Lines/
	  doins -r ./

	  # KDM theme
	  cd ${S}/kdm
	  insinto ${ROOT}/$kdedir/share/apps/kdm/themes/
	  doins -r ./

	fi

	# Gensplash theme
	cd ${S}/gensplash
        dodir /etc/splash/sabayon
        cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Emerald theme
	#cd ${S}/emerald
	#dodir ${ROOT}/usr/share/emerald/themes
	#insinto ${ROOT}/usr/share/emerald/themes
	#doins -r ./

	cd ${S}/mouse/PolarCursor/cursors/
	dodir /usr/share/cursors/xorg-x11/PolarCursorTheme/cursors
	insinto /usr/share/cursors/xorg-x11/PolarCursorTheme/cursors/
	doins -r ./
	
	cd ${S}/mouse/PolarCursor
	dodir /usr/share/cursors/xorg-x11/default
	exeinto /usr/share/cursors/xorg-x11/default
	echo "Inherits=PolarCursorTheme" > index.theme
	doexe ./index.theme		

	# KDE Theme
	dodir /usr/share/apps/kthememanager/themes
	insinto	 /usr/share/apps/kthememanager/themes
	cd ${S}/kde
	mkdir Sabayon\ Linux
	tar xf Sabayon\ Linux.kth -C Sabayon\ Linux
	rm *.kth
	doins -r ./

	# Beryl cube theme
	cd ${S}/compiz
	dodir /usr/share/compiz
	insinto /usr/share/compiz/
	doins *.png

}
