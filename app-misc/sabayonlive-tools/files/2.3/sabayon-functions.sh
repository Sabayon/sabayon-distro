#!/bin/bash

GDM_FILE="/usr/share/gdm/defaults.conf"
CUSTOM_GDM_FILE="/etc/gdm/custom.conf"
KDM_FILE="/usr/share/config/kdm/kdmrc"
LXDM_FILE="/etc/lxdm/lxdm.conf"
OEM_FILE="/etc/oemlive.sh"
OEM_FILE_NEW="/etc/oem/liveboot.sh"
LIVE_USER_GROUPS="audio cdrom cdrw clamav console entropy games haldaemon \
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

	elif [ -f "${CUSTOM_GDM_FILE}" ]; then
		sed -i "s:\[daemon\]:\[daemon\]\nAutomaticLoginEnable=true\nAutomaticLogin=${LIVE_USER}\nTimedLoginEnable=true\nTimedLogin=${LIVE_USER}\nTimedLoginDelay=0:" \
			"${CUSTOM_GDM_FILE}"
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

	# LXDM
	if [ -f "$LXDM_FILE" ]; then
		sed -i "s/autologin=.*/autologin=${LIVE_USER}/" $LXDM_FILE
		sed -i "/^#.*autologin=/ s/^#//" $LXDM_FILE
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
	if [ -x "${OEM_LIVE_NEW}" ]; then
		${OEM_FILE_NEW} || return 1
	elif [ -x "${OEM_LIVE}" ]; then
		${OEM_FILE} || return 1
	fi
	return 0
}

sabayon_is_live() {
	local cmdl=$(cat /proc/cmdline | grep cdroot)
	if [ -n "${cmdl}" ]; then
		return 0
	else
		return 1
	fi
}

sabayon_setup_gui_installer() {
	# Configure Fluxbox
	local dmrc_file="/home/${LIVE_USER}/.dmrc"
	local flux_dir="/home/${LIVE_USER}/.fluxbox"
	local flux_startup_file="${flux_dir}/startup"
	if [ ! -d "${flux_dir}" ]; then
		mkdir "${flux_dir}" && chown "${LIVE_USER}" "${flux_dir}"
	fi
	echo "[Desktop]" > "${dmrc_file}"
	echo "Session=fluxbox" >> "${dmrc_file}"
	chown sabayonuser "${dmrc_file}"
	sed -i "/installer --fullscreen/ s/^# //" "${flux_startup_file}"
}

sabayon_setup_text_installer() {
	# switch to verbose mode
	splash_manager -c set -t default -m v &> /dev/null
	reset
	chvt 1
	clear
	echo "Welcome to Sabayon Linux Text installation." >> /etc/motd
	echo "root password: root" >> /etc/motd
	echo "to run the installation type: installer <and PRESS ENTER>" >> /etc/motd
}

sabayon_is_text_install() {
	local _is_install=$(cat /proc/cmdline | grep installer-text)
	if [ -n "${_is_install}" ]; then
		return 0
	else
		return 1
	fi
}

sabayon_is_gui_install() {
	local _is_install=$(cat /proc/cmdline | grep installer-gui)
	if [ -n "${_is_install}" ]; then
		return 0
	else
		return 1
	fi
}

sabayon_is_live_install() {
	( sabayon_is_text_install || sabayon_is_gui_install ) && return 0
	return 1
}
