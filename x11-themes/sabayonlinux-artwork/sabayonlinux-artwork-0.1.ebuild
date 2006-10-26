# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official artwork, can include wallpapers and GTK/QT Themes."
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="http://www.sabayonlinuxdev.com/distfiles/x11-themes/${PN}/${PN}-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 sparc amd64 ppc"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.8"


RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {

	if [ ! -e /usr/share/backgrounds ]; then
          dodir /usr/share/backgrounds
        fi

	if [ ! -e /usr/share/themes ]; then
          dodir /usr/share/themes
        fi

	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.jpg

	cd ${S}/gtk
	insinto /usr/share/themes
	doins -r ./

	if [ -e /usr/kde/3.5 ]; then
	  kdedir="/usr/kde/3.5"
	elif [ -e /usr/kde/3.4 ]; then
	  kdedir="/usr/kde/3.4"
	else
	  kdedir="nokde"	
	fi

	if [ "$kdedir" != "nokde" ] && [ -e "$kdedir/share/apps/ksplash/Themes" ]; then
	  cd ${S}/ksplash
	  insinto $kdedir/share/apps/ksplash/Themes
	  doins -r ./
	fi

}
