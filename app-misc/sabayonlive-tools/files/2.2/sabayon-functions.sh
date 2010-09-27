#!/bin/bash

GDM_FILE="/usr/share/gdm/defaults.conf"
KDM_FILE="/usr/share/config/kdm/kdmrc"
OEM_FILE="/etc/oemlive.sh"
LIVE_USER_GROUPS="audio cdrom cdrw clamav console disk entropy games haldaemon \
kvm lp lpadmin messagebus plugdev polkituser portage pulse pulse-access pulse-rt \
scanner usb users uucp vboxguest vboxusers video wheel"
LIVE_USER=${SABAYON_USER:-sabayonuser}

sabayon_setup_autologin() {

	# GDM - GNOME
	if [ -f "${GDM_FILE}" ]; then
		sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=true/" ${GDM_FILE}
		sed -i "s/^AutomaticLogin=.*/AutomaticLogin=${LIVE_USER}/" ${GDM_FILE}

		sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=true/" ${GDM_FILE}
		sed -i "s/^TimedLogin=.*/TimedLogin=${LIVE_USER}/" ${GDM_FILE}
		sed -i "s/^TimedLoginDelay=.*/TimedLoginDelay=0/" ${GDM_FILE}

	fi

	# KDM - KDE
	if [ -f "$KDM_FILE" ]; then
		sed -i "s/AutoLoginEnable=.*/AutoLoginEnable=true/" $KDM_FILE
		sed -i "s/AutoLoginUser=.*/AutoLoginUser=${LIVE_USER}/" $KDM_FILE
		sed -i "s/AutoLoginDelay=.*/AutoLoginDelay=0/" $KDM_FILE
		sed -i "s/AutoLoginAgain=.*/AutoLoginAgain=true/" $KDM_FILE

		sed -i "s/AllowRootLogin=.*/AllowRootLogin=true/" $KDM_FILE
		sed -i "s/AllowNullPasswd=.*/AllowNullPasswd=true/" $KDM_FILE
		sed -i "s/AllowShutdown=.*/AllowShutdown=All/" $KDM_FILE

		sed -i "/^#.*AutoLoginEnable=/ s/^#//" $KDM_FILE
		sed -i "/^#.*AutoLoginUser=/ s/^#//" $KDM_FILE
		sed -i "/^#.*AutoLoginDelay=/ s/^#//" $KDM_FILE
		sed -i "/^#.*AutoLoginAgain=/ s/^#//" $KDM_FILE

		sed -i "/^#AllowRootLogin=/ s/^#//" $KDM_FILE
		sed -i "/^#AllowNullPasswd=/ s/^#//" $KDM_FILE
		sed -i "/^#AllowShutdown=/ s/^#//" $KDM_FILE
	fi

}

sabayon_disable_autologin() {

	# GDM - GNOME
	if [ -f "${GDM_FILE}" ]; then
		sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=false/" ${GDM_FILE}
	fi

	# KDM - KDE
	KDM_FILE="/usr/share/config/kdm/kdmrc"
	if [ -f "$KDM_FILE" ]; then
		sed -i "s/AutoLoginEnable=.*/AutoLoginEnable=false/" $KDM_FILE
	fi

}

sabayon_setup_live_user() {
	local live_user="${1}"
	local live_uid="${2}"
	if [ -z "${live_user}" ]; then
		live_user="${LIVE_USER}"
	fi
	if [ -n "${live_uid}" ]; then
		live_uid="-u ${live_uid}"
	fi
	id ${live_user} &> /dev/null
	if [ "${?}" != "0" ]; then
		local live_groups=""
		local avail_groups=$(cat /etc/group | cut -d":" -f 1 | xargs echo)
		for a_group in ${avail_groups}; do
			for p_group in ${LIVE_USER_GROUPS}; do
				if [ "${p_group}" = "${a_group}" ]; then
					if [ -z "${live_groups}" ]; then
						live_groups="${p_group}"
					else
						live_groups="${live_groups},${p_group}"
					fi
				fi
			done
		done
		# then setup live user, that is missing
		useradd -d "/home/${live_user}" -g root -G ${live_groups} \
			-m -N -p "" -s /bin/bash ${live_uid} "${live_user}"
		return 0
	fi
	return 1
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
	( [[ -x "${OEM_FILE}" ]] && ${OEM_FILE} ) || return 0
}
