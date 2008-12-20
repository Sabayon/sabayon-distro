# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official artwork, can include wallpapers, ksplash, and GTK/QT Themes."
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://www.sabayonlinux.org/distfiles/x11-themes/${PN}/${P}.tar.lzma"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="+gnome +kde +compiz +gdm +kdm"
RESTRICT="nomirror"
RDEPEND="
	!<x11-themes/sabayonlinux-artwork-4
	!x11-themes/sabayon-artwork-star
	!x11-themes/sabayon-artwork-darkblend
	"

S="${WORKDIR}/${PN}"

src_install () {

	dodir /usr/share/backgrounds
	dodir /usr/share/themes
	dodir /etc/splash
	
	if use gnome ; then
		cd ${S}/gtk
		dodir /usr/share/theme
		insinto /usr/share/themes
		doins -r ./*

		# Metacity
		cd ${S}/metacity
		insinto /usr/share/themes
		doins -r ./*

		# GNOME splash
		cd ${S}/gnome-splash
		dodir /usr/share/pixmaps/splash
		insinto /usr/share/pixmaps/splash
		doins *.png
	fi

	if use gdm ; then
		# GDM Theme
		cd ${S}/gdm
		dodir /usr/share/gdm/themes
		insinto /usr/share/gdm/themes/
		doins -r ./*
	fi

	if use kdm ; then
		# KDM theme
		cd ${S}/kdm
		mv Sabayon-4.0 Sabayon
		mv Sabayon-4.0-wide Sabayon-wide
		insinto /usr/kde/3.5/share/apps/kdm/themes/
		doins -r ./
	fi

	if use kde ; then
		#ksplash
		cd ${S}/ksplash/Lines
		dodir /usr/kde/3.5/share/apps/ksplash/Themes/Lines
		insinto /usr/kde/3.5/share/apps/ksplash/Themes/Lines
		doins -r ./
		
		# KDE Theme
		dodir /usr/share/apps/kthememanager/themes
		insinto /usr/share/apps/kthememanager/themes
		cd ${S}/kde
		mkdir Sabayon4
		tar xf Sabayon4.kth -C Sabayon4
		rm *.kth
		doins -r ./
	fi

	if use compiz ; then
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
	fi

	#SYSTEM
	# Gensplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Cursors
	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	# Wallpaper
	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.png

	# Install settings for existing users
	addwrite /home
	for user in /home/*; do
		if [ ! -e "$user/.config" ]; then
			username=$(echo $user | cut -d/ -f3)
			if [ -n "`cat /etc/passwd | grep ^$username`" ]; then
				# Install Compiz Setting
				if use compiz; then
					mkdir $user/.config/compiz/compizconfig -p &> /dev/null
					cp ${FILESDIR}/compiz-fusion-config/Default.ini $user/.config/compiz/compizconfig/
					cp ${FILESDIR}/compiz-fusion-config/config $user/.config/compiz/compizconfig/
					chown $username $user/.config -R
				fi

				if use kde ; then
					# Fix Taskbar
					cp ${FILESDIR}/ktaskbarrc $user/.kde/share/config/
					chown $username $user/.kde/share/config/ktaskbarrc
				fi

				# Fix Userimage
				cp ${S}/misc/userface.png $user/.face.icon
				cp ${S}/misc/userface.png /etc/.skel/.face.icon
				chown $username $user/.face.icon
			fi
		fi
	done
}

pkg_postinst () {
	# Update ksplash cache
	for i in `ls /home`
	do
	rm -r /home/$i/.kde3.5/share/apps/ksplash/cache/ 2> /dev/null
	# set Gnome Panel images - DISABLED for the moment
	#gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults xml:readwrite:/etc/gconf/gconf.xml.defaults --set --type string /apps/panel/default_setup/toplevels/top_panel/background/type "image"
	#gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults xml:readwrite:/etc/gconf/gconf.xml.defaults --set --type string /apps/panel/default_setup/toplevels/bottom_panel/background/type "image"
	# set BG
	#gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults xml:readwrite:/etc/gconf/gconf.xml.defaults --set --type string /apps/panel/default_setup/toplevels/top_panel/background/image "/usr/share/backgrounds/menu-gnome.png"
	#gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults xml:readwrite:/etc/gconf/gconf.xml.defaults --set --type string /apps/panel/default_setup/toplevels/bottom_panel/background/image "/usr/share/backgrounds/menu-gnome.png"
	done

	elog "It is reccomended you recompile your kernel to get"
	elog "the new gensplash and to avoid any glitches"
	elog " "
	elog "To get the GRUB artwork install the latest GRUB"
	elog " "
	ewarn "This Is a Release Candidate, so things"
	ewarn "SHOULD NOT be missing. Please report bugs"
	ewarn "or glitches to ian.whyman@sabayonlinux.org or"
	ewarn "to Thev00d00 or irc.freenode.net #sabayon"
}
