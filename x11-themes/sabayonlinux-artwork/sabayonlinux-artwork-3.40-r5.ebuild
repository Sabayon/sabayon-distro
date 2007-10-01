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
IUSE="symlink professional_edition kde gtk"
RESTRICT="nomirror"
RDEPEND="
	gtk? ( >=x11-libs/gtk+-2.8 )
	kde? ( kde-base/kdelibs )
	"


RDEPEND=""

S="${WORKDIR}/${PN}"

src_install () {

	dodir /usr/share/backgrounds
	dodir /usr/share/themes
	dodir /etc/splash

	cd ${S}/background
	insinto /usr/share/backgrounds
	if use professional_edition; then
		mv  sabayonlinux-pe.png sabayonlinux.png
		cp sabayonlinux.png ../ksplash/Lines/Background.png
		cp sabayonlinux.png ../ksplash/Lines/Preview.png
	else
		cp sabayonlinux.png ../ksplash/Lines/Background.png
                cp sabayonlinux.png ../ksplash/Lines/Preview.png
		fi
	doins *.jpg *.png

	if use gnome; then

	  cd ${S}/gtk
	  insinto /usr/share/themes
	  doins -r ./

	  cd ${S}/metacity
	  insinto /usr/share/themes
	  doins -r ./

	  # GNOME splash
	  cd ${S}/gnome-splash
	  insinto /usr/share/pixmaps/splash
	  doins *.png

	  # GDM Theme
	  cd ${S}/gdm
	  insinto /usr/share/gdm/themes/
	  doins -r ./

	  # copy custom gdm config over
	  dodir /etc/X11/gdm
	  insinto /etc/X11/gdm
	  doins ${FILESDIR}/custom.conf

	fi

	if use kde; then

	  cd ${S}/ksplash/Lines
	  dodir /usr/share/apps/ksplash/Themes/Lines
	  insinto /usr/share/apps/ksplash/Themes/Lines/
	  doins -r ./

	  # KDM theme
	  cd ${S}/kdm
	  insinto /usr/kde/3.5/share/apps/kdm/themes/
	  doins -r ./

	  # KDE Theme
	  dodir /usr/share/apps/kthememanager/themes
	  insinto /usr/share/apps/kthememanager/themes
	  cd ${S}/kde
	  mkdir Sabayon\ Linux
	  tar xf Sabayon\ Linux.kth -C Sabayon\ Linux
	  rm *.kth
	  doins -r ./

	# KDE Icon themes
          insinto /usr/share/icons/
          cd ${S}/kdeicons
          tar xf sabayonicons.tar
          rm *.tar
          doins -r ./


	fi

	# Gensplash theme
	cd ${S}/gensplash
        dodir /etc/splash/sabayon
        cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Emerald theme
	#cd ${S}/emerald
	#dodir /usr/share/emerald/themes
	#insinto /usr/share/emerald/themes
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

	# Beryl cube theme
	cd ${S}/compiz
	dodir /usr/share/compiz
	insinto /usr/share/compiz/
	doins *.png

	# Compiz fusion stuff

        # Install Settings
        if [ -d "/etc/skel/.config" ]; then
                dodir /etc/skel/.config/compiz/compizconfig
                insinto /etc/skel/.config/compiz/compizconfig
                doins ${FILESDIR}/compiz-fusion-config/config
                doins ${FILESDIR}/compiz-fusion-config/Default.ini
	
        fi

        # hackish thing...
        addwrite /home
        for user in /home/*; do
                if [ ! -e "$user/.config" ]; then
                        username=$(echo $user | cut -d/ -f3)
                        if [ -n "`cat /etc/passwd | grep ^$username`" ]; then
                                mkdir $user/.config/compiz/compizconfig -p &> /dev/null
                                cp ${FILESDIR}/compiz-fusion-config/Default.ini $user/.config/compiz/compizconfig/
                                cp ${FILESDIR}/compiz-fusion-config/config $user/.config/compiz/compizconfig/
                                chown $username $user/.config -R
                        fi
                fi
        done


}
