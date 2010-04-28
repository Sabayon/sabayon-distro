#!/bin/bash

gdm_file="/usr/share/gdm/defaults.conf"
kdm_file="/usr/share/config/kdm/kdmrc"
oem_file="/etc/oemlive.sh"

sabayon_setup_autologin() {

	local sabayon_user=${SABAYON_USER:-sabayonuser}

	# GDM - GNOME
	if [ -f "${gdm_file}" ]; then
		sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=true/" ${gdm_file}
		sed -i "s/^AutomaticLogin=.*/AutomaticLogin=${sabayon_user}/" ${gdm_file}

		sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=true/" ${gdm_file}
		sed -i "s/^TimedLogin=.*/TimedLogin=${sabayon_user}/" ${gdm_file}
		sed -i "s/^TimedLoginDelay=.*/TimedLoginDelay=0/" ${gdm_file}

	fi

	# KDM - KDE
	if [ -f "$kdm_file" ]; then
		sed -i "s/AutoLoginEnable=.*/AutoLoginEnable=true/" $kdm_file
		sed -i "s/AutoLoginUser=.*/AutoLoginUser=${sabayon_user}/" $kdm_file
		sed -i "s/AutoLoginDelay=.*/AutoLoginDelay=0/" $kdm_file
		sed -i "s/AutoLoginAgain=.*/AutoLoginAgain=true/" $kdm_file

		sed -i "s/AllowRootLogin=.*/AllowRootLogin=true/" $kdm_file
		sed -i "s/AllowNullPasswd=.*/AllowNullPasswd=true/" $kdm_file
		sed -i "s/AllowShutdown=.*/AllowShutdown=All/" $kdm_file

		sed -i "/^#.*AutoLoginEnable=/ s/^#//" $kdm_file
		sed -i "/^#.*AutoLoginUser=/ s/^#//" $kdm_file
		sed -i "/^#.*AutoLoginDelay=/ s/^#//" $kdm_file
		sed -i "/^#.*AutoLoginAgain=/ s/^#//" $kdm_file

		sed -i "/^#AllowRootLogin=/ s/^#//" $kdm_file
		sed -i "/^#AllowNullPasswd=/ s/^#//" $kdm_file
		sed -i "/^#AllowShutdown=/ s/^#//" $kdm_file
	fi

}

sabayon_disable_autologin() {

	# GDM - GNOME
	if [ -f "${gdm_file}" ]; then
		sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=false/" ${gdm_file}
	fi

	# KDM - KDE
	kdm_file="/usr/share/config/kdm/kdmrc"
	if [ -f "$kdm_file" ]; then
		sed -i "s/AutoLoginEnable=.*/AutoLoginEnable=false/" $kdm_file
	fi

}

sabayon_setup_motd() {
	echo -e "\n\tWelcome to `cat /etc/sabayon-edition`\n\t`uname -p`\n\t`uname -o` `uname -r`\n" > /etc/motd
}

sabayon_setup_vt_autologin() {
	source /sbin/livecd-functions.sh
	export CDBOOT=1
	livecd_fix_inittab
}

sabayon_setup_oem_livecd() {
	[[ -x "${oem_file}" ]] && ${oem_file}
}
