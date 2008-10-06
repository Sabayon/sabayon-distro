# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official artwork, can include wallpapers, ksplash, and GTK/QT Themes."
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://zenana.v00d00.net/files/distfiles/${PN}-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64"
IUSE="symlink"
RESTRICT="nomirror"
RDEPEND=">=x11-wm/compiz-fusion-0.7.8"

S="${WORKDIR}/${PN}"

pkg_setup () {
	# Hack to stop file collisions
	rm -r ${ROOT}/usr/kde/3.5/share/apps/ksplash/Themes/Lines/
}

src_install () {

	dodir /usr/share/backgrounds
	dodir /usr/share/themes
	dodir /etc/splash

	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.jpg *.png

	cd ${S}/gtk
	dodir /usr/share/theme
	insinto /usr/share/themes
	doins -r ./*

	cd ${S}/metacity
	insinto /usr/share/themes
	doins -r ./*

	# GNOME splash
	cd ${S}/gnome-splash
	dodir /usr/share/pixmaps/splash
	insinto /usr/share/pixmaps/splash
	doins *.png

	# GDM Theme
	cd ${S}/gdm
	dodir /usr/share/gdm/themes
	insinto /usr/share/gdm/themes/
	doins -r ./*

	#ksplash
	cd ${S}/ksplash/Lines
	dodir /usr/kde/3.5/share/apps/ksplash/Themes/Lines
	insinto /usr/kde/3.5/share/apps/ksplash/Themes/Lines
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


	# Gensplash theme
	cd ${S}/gensplash
        dodir /etc/splash/sabayon
        cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Cursors
	cd ${S}/mouse/PolarCursor/cursors/
	dodir /usr/share/cursors/xorg-x11/PolarCursorTheme/cursors
	insinto /usr/share/cursors/xorg-x11/PolarCursorTheme/cursors/
	doins -r ./

	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	cd ${S}/mouse/Obsidian/cursors/
	dodir /usr/share/cursors/xorg-x11/Obsidian/cursors
	insinto /usr/share/cursors/xorg-x11/Obsidian/cursors/
	doins -r ./
	
	dodir /usr/share/cursors/xorg-x11/default
	exeinto /usr/share/cursors/xorg-x11/default
	echo "Inherits=Obsidian" > index.theme
	doexe ./index.theme		

	# Compiz cube theme
	cd ${S}/compiz
	dodir /usr/share/compiz
	insinto /usr/share/compiz/
	doins *.png

	# Emerald theme
	cd ${S}/emerald
	dodir /usr/share/emerald/themes
	insinto /usr/share/emerald/themes/
	doins -r ./

	# Compiz fusion stuff

        # Install Settings
        if [ -d "/etc/skel/.config" ]; then
                dodir /etc/skel/.config/compiz/compizconfig
                insinto /etc/skel/.config/compiz/compizconfig
                doins ${FILESDIR}/compiz-fusion-config/config
                doins ${FILESDIR}/compiz-fusion-config/Default.ini
	
        fi

        # hackish thing... (installing compiz settings)
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

pkg_postinst () {
        ewarn "its alpha! ok?!"
	# Update ksplash cache
	for i in `ls /home`
	do
	rm -r /home/$i/.kde3.5/share/apps/ksplash/cache/ 2> /dev/null
	done
}
