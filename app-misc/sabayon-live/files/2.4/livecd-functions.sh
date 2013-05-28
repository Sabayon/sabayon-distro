#!/bin/bash

# Global Variables:
#    CDBOOT                  -- is booting off CD
#    LIVECD_CONSOLE          -- console that is specified on commandline 
#                            -- (ttyS0, etc) Only defined if passed to kernel
#    LIVECD_CONSOLE_BAUD     -- console baudrate specified
#    LIVECD_CONSOLE_PARITY   -- console parity specified
#    LIVECD_CONSOLE_DATABITS -- console databits specified

[[ ${RC_GOT_FUNCTIONS} != "yes" ]] && \
	[[ -e /etc/init.d/functions.sh ]] && \
	source /etc/init.d/functions.sh

# emulating einfo since it's not always available from functions.sh
# FIXME: fix functions.sh
einfo() {
	[[ -x "/lib/rc/bin/einfo" ]] && /lib/rc/bin/einfo "${1}"\
		|| echo "* ${1}"
}

livecd_parse_opt() {
	case "$1" in
		*\=*)
			echo "$1" | cut -f2 -d=
		;;
	esac
}

livecd_check_root() {
	if [ "$(whoami)" != "root" ]
	then
		echo "ERROR: must be root to continue"
		return 1
	fi
}

livecd_get_cmdline() {
	echo "0" > /proc/sys/kernel/printk
	CMDLINE=$(cat /proc/cmdline)
	export CMDLINE
}

no_gl() {
#	einfo "If you have a card that you know is supported by either the ATI or"
#	einfo "NVIDIA binary drivers, please file a bug with the output of lspci"
#	einfo "on http://bugs.gentoo.org so we can resolve this."
	GLTYPE=xorg-x11
}

ati_gl() {
	einfo "ATI card detected."
	if [ -e /usr/lib/xorg/modules/drivers/fglrx_drv.so ] \
	|| [ -e /usr/lib/modules/drivers/fglrx_drv.so ]
	then
		GLTYPE=ati
	else
		GLTYPE=xorg-x11
	fi
}

nv_gl() {
	einfo "NVIDIA card detected."
	if [ -e /usr/lib/xorg/modules/drivers/nvidia_drv.so ] \
	|| [ -e /usr/lib/modules/drivers/nvidia_drv.so ]
	then
		GLTYPE=nvidia
	else
		GLTYPE=xorg-x11
	fi
}

nv_no_gl() {
	einfo "NVIDIA card detected."
	echo
	if [ -e /usr/lib/xorg/modules/drivers/nvidia_drv.so ] \
	|| [ -e /usr/lib/modules/drivers/nvidia_drv.so ]
	then
		einfo "This card is not supported by the latest version of the NVIDIA"
		einfo "binary drivers.  Switching to the X server's driver instead."
	fi
	GLTYPE=xorg-x11
	sed -i 's/nvidia/nv/' /etc/X11/xorg.conf
}

get_video_cards() {
	[ -x /sbin/lspci ] && VIDEO_CARDS="$(/sbin/lspci | grep ' VGA ')"
	[ -x /usr/sbin/lspci ] && VIDEO_CARDS="$(/usr/sbin/lspci | grep ' VGA ')"
	#NUM_CARDS="$(echo ${VIDEO_CARDS} | wc -l)"
	#if [ ${NUM_CARDS} -eq 1 ] # Disabled to support NVIDIA SLI devices
	#then
		NVIDIA=$(echo ${VIDEO_CARDS} | grep -i "nVidia Corporation")
		ATI=$(echo ${VIDEO_CARDS} | grep -i "ATI Technologies")
		if [ -n "${NVIDIA}" ]
		then
			# Always set NVIDIA OpenGL, since it's stupid doing the contrary because:
			# there's no X.Org free driver that supports OpenGL through MESA
			nv_gl
		elif [ -n "${ATI}" ]
		then
			ATI_CARD=$(echo ${ATI} | awk 'BEGIN {RS=" "} /(R|RV|RS|M)[0-9]+/ {print $1}')
			if [ $(echo ${ATI_CARD} | grep S) ]
			then
				ATI_CARD_OUT=$(echo ${ATI_CARD} | cut -dS -f2)
			elif [ $(echo ${ATI_CARD} | grep V) ]
			then
				ATI_CARD_OUT=$(echo ${ATI_CARD} | cut -dV -f2)
			elif [ $(echo ${ATI_CARD} | grep M)  ]
			then
				# ATI Technologies Inc. M52 [ ATI Mobility Radeon X1300 ]
				ATI_CARD_OUT=$(echo ${ATI_CARD} | cut -dM -f2)
			else
				ATI_CARD_OUT=$(echo ${ATI_CARD} | cut -dR -f2)
			fi

			if [ -n "${ATI_CARD_OUT}" ] && [ ${ATI_CARD_OUT} -ge 300 ]
			then
				ati_gl
			elif [ -n "${ATI_CARD_OUT}" ] && [ -n "`echo ${ATI_CARD} | grep M`" ]
			then
				# this is an ATI Mxx card
				ati_gl
			# >8.29.6 does not support R200 anymore
			elif [ -n "${ATI_CARD_OUT}" ] && [ ${ATI_CARD_OUT} -ge 200 ]
			then
				no_gl
			else
				# set ATI OpenGL anyway
				ati_gl
			fi
		else
			no_gl
		fi
	#fi
}

livecd_config_wireless() {
	cd /tmp/setup.opts
	[ -x /usr/sbin/iwconfig ] && iwconfig=/usr/sbin/iwconfig
	[ -x /sbin/iwconfig ] && iwconfig=/sbin/iwconfig
	dialog --title "SSID" --inputbox "Please enter your SSID, or leave blank for selecting the nearest open network" 20 50 2> ${iface}.SSID
	SSID=$(tail -n 1 ${iface}.SSID)
	if [ -n "${SSID}" ]
	then
		dialog --title "WEP (Part 1)" --menu "Does your network use encryption?" 20 60 7 1 "Yes" 2 "No" 2> ${iface}.WEP
		WEP=$(tail -n 1 ${iface}.WEP)
		case ${WEP} in
			1)
				dialog --title "WEP (Part 2)" --menu "Are you entering your WEP key in HEX or ASCII?" 20 60 7 1 "HEX" 2 "ASCII" 2> ${iface}.WEPTYPE
				WEP_TYPE=$(tail -n 1 ${iface}.WEPTYPE)
				case ${WEP_TYPE} in
					1)
						dialog --title "WEP (Part 3)" --inputbox "Please enter your WEP key in the form of XXXX-XXXX-XX for 64-bit or XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XX for 128-bit" 20 50 2> ${iface}.WEPKEY
						WEP_KEY=$(tail -n 1 ${iface}.WEPKEY)
						if [ -n "${WEP_KEY}" ]
						then
							${iwconfig} ${iface} essid "${SSID}"
							${iwconfig} ${iface} key "${WEP_KEY}"
						fi
					;;
					2)
						dialog --title "WEP (Part 3)" --inputbox "Please enter your WEP key in ASCII form.  This should be 5 or 13 characters for either 64-bit or 128-bit encryption, repectively" 20 50 2> ${iface}.WEPKEY
						WEP_KEY=$(tail -n 1 ${iface}.WEPKEY)
						if [ -n "${WEP_KEY}" ]
						then
							${iwconfig} ${iface} essid "${SSID}"
							${iwconfig} ${iface} key "s:${WEP_KEY}"
						fi
					;;
				esac
			;;
			2)
				${iwconfig} ${iface} essid "${SSID}"
				${iwconfig} ${iface} key off
			;;
		esac
	fi
}

livecd_write_wireless_conf() {
	cd /tmp/setup.opts
	SSID=$(tail -n 1 ${iface}.SSID)
	if [ -n "${SSID}" ]
	then
		echo "" >> /etc/conf.d/net
		echo "# This wireless configuration file was built by net-setup" > /etc/conf.d/net
		WEP=$(tail -n 1 ${iface}.WEPTYPE)
		case ${WEP} in
			1)
				WEP_TYPE=$(tail -n 1 ${iface}.WEPTYPE)
				if [ -n "${WEP_TYPE}" ]
				then
					WEP_KEY=$(tail -n 1 ${iface}.WEPKEY)
					if [ -n "${WEP_KEY}" ]
					then
						SSID_TRANS=$(echo ${SSID//[![:word:]]/_})
						case ${WEP_TYPE} in
							1)
								echo "key_${SSID_TRANS}=\"${WEP_KEY} enc open\"" >> /etc/conf.d/net
							;;
							2)
								echo "key_${SSID_TRANS}=\"s:${WEP_KEY} enc open\"" >> /etc/conf.d/net
							;;
						esac
					fi
				fi
			;;
			2)
				:
			;;
		esac
		echo "preferred_aps=( \"${SSID}\" )" >> /etc/conf.d/net
		echo "associate_order=\"forcepreferredonly\"" >> /etc/conf.d/net
	fi
}

livecd_config_ip() {
	cd /tmp/setup.opts
	dialog --title "TCP/IP setup" --menu "You can use DHCP to automatically configure a network interface or you can specify an IP and related settings manually. Choose one option:" 20 60 7 1 "Use DHCP to auto-detect my network settings" 2 "Specify an IP address manually" 2> ${iface}.DHCP
	DHCP=$(tail -n 1 ${iface}.DHCP)
	case ${DHCP} in
		1)
			/sbin/dhclient -q -r -nw ${iface} &
		;;
		2)
			dialog --title "IP address" --inputbox "Please enter an IP address for ${iface}:" 20 50 "192.168.1.1" 2> ${iface}.IP
			IP=$(tail -n 1 ${iface}.IP)
			BC_TEMP=$(echo $IP|cut -d . -f 1).$(echo $IP|cut -d . -f 2).$(echo $IP|cut -d . -f 3).255
			dialog --title "Broadcast address" --inputbox "Please enter a Broadcast address for ${iface}:" 20 50 "${BC_TEMP}" 2> ${iface}.BC
			BROADCAST=$(tail -n 1 ${iface}.BC)
			dialog --title "Network mask" --inputbox "Please enter a Network Mask for ${iface}:" 20 50 "255.255.255.0" 2> ${iface}.NM
			NETMASK=$(tail -n 1 ${iface}.NM)
			dialog --title "Gateway" --inputbox "Please enter a Gateway for ${iface} (hit enter for none:)" 20 50 2> ${iface}.GW
			GATEWAY=$(tail -n 1 ${iface}.GW)
			dialog --title "DNS server" --inputbox "Please enter a name server to use (hit enter for none:)" 20 50 2> ${iface}.DNS
			DNS=$(tail -n 1 ${iface}.DNS)
			/sbin/ifconfig ${iface} ${IP} broadcast ${BROADCAST} netmask ${NETMASK}
			if [ -n "${GATEWAY}" ]
			then
				/sbin/route add default gw ${GATEWAY} dev ${iface} netmask 0.0.0.0 metric 1
			fi
			if [ -n "${DNS}" ]
			then
				dialog --title "DNS Search Suffix" --inputbox "Please enter any domains which you would like to search on DNS queries (hit enter for none:)" 20 50 2> ${iface}.SUFFIX
				SUFFIX=$(tail -n 1 ${iface}.SUFFIX)
				echo "nameserver ${DNS}" > /etc/resolv.conf
				if [ -n "${SUFFIX}" ]
				then
					echo "search ${SUFFIX}" >> /etc/resolv.conf
				fi
			fi
		;;
	esac
}

livecd_write_net_conf() {
	cd /tmp/setup.opts
	echo "# Sabayon Linux static network configuration tool" > /etc/conf.d/net
	DHCP=$(tail -n 1 ${iface}.DHCP)
	case ${DHCP} in
		1)
			echo "config_${iface}=\"dhcp\"" >> /etc/conf.d/net
			echo "dhcp_${iface}=\"nosendhost\"" >> /etc/conf.d/net
		;;
		2)
			IP=$(tail -n 1 ${iface}.IP)
			BROADCAST=$(tail -n 1 ${iface}.BC)
			NETMASK=$(tail -n 1 ${iface}.NM)
			GATEWAY=$(tail -n 1 ${iface}.GW)
			DNS="$(tail -n 1 ${iface}.DNS)"
			DOMAIN="$(tail -n 1 ${iface}.SUFFIX)"
			if [ -n "${IP}" -a -n "${BROADCAST}" -a -n "${NETMASK}" ]
			then
				echo "config_${iface}=\"${IP} netmask ${NETMASK} broadcast ${BROADCAST}\"" >> /etc/conf.d/net
				if [ -n "${GATEWAY}" ]
				then
					echo "routes_${iface}=\"default via ${GATEWAY}\"" >> /etc/conf.d/net
				fi
				if [ -n "${DNS}" ]
				then
					echo "dns_servers_${iface}=\"${DNS}\"" >> /etc/conf.d/net
				fi
				if [ -n "${DOMAIN}" ]
				then
					echo "dns_search_${iface}=\"${DOMAIN}\"" >> /etc/conf.d/net
				fi
			fi
		;;
	esac
}

get_ifmac() {
	local iface=$1

	# Example: 00:01:6f:e1:7a:06
	cat /sys/class/net/${iface}/address
}


get_ifdriver() {
	local iface=$1

	# Example: ../../../bus/pci/drivers/forcedeth (wanted: forcedeth)
	local if_driver=$(readlink /sys/class/net/${iface}/device/driver)
	basename ${if_driver}
}

get_ifbus() {
	local iface=$1

	# Example: ../../../bus/pci (wanted: pci)
	# Example: ../../../../bus/pci (wanted: pci)
	# Example: ../../../../../../bus/usb (wanted: usb)
	local if_bus=$(readlink /sys/class/net/${iface}/device/bus)
	basename ${if_bus}
}

livecd_rev_string() {
	# See Sabayon #2522, cannot use /usr/bin/rev because
	# /usr might not be mounted
	local copy=${1}
	len=${#copy}
	for((i=$len-1;i>=0;i--)); do rev="$rev${copy:$i:1}"; done
	echo ${rev}
}

get_ifproduct() {
	local iface=$1
	local bus=$(get_ifbus ${iface})
	local if_pciaddr
	local if_devname
	local if_usbpath
	local if_usbmanufacturer
	local if_usbproduct

	if [[ ${bus} == "pci" ]]
	then
		# Example: ../../../devices/pci0000:00/0000:00:0a.0 (wanted: 0000:00:0a.0)
		# Example: ../../../devices/pci0000:00/0000:00:09.0/0000:01:07.0 (wanted: 0000:01:07.0)
		if_pciaddr=$(readlink /sys/class/net/${iface}/device)
		if_pciaddr=$(basename ${if_pciaddr})

		# Example: 00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
		#  (wanted: nVidia Corporation CK804 Ethernet Controller)
		if_devname=$(lspci -s ${if_pciaddr})
		if_devname=${if_devname#*: }
		if_devname=${if_devname%(rev *)}
	fi

	if [[ ${bus} == "usb" ]]
	then
		if_usbpath=$(readlink /sys/class/net/${iface}/device)
		if_usbpath=/sys/class/net/${iface}/$(dirname ${if_usbpath})
		if_usbmanufacturer=$(< ${if_usbpath}/manufacturer)
		if_usbproduct=$(< ${if_usbpath}/product)

		[[ -n ${if_usbmanufacturer} ]] && if_devname="${if_usbmanufacturer} "
		[[ -n ${if_usbproduct} ]] && if_devname="${if_devname}${if_usbproduct}"
	fi

	if [[ ${bus} == "ieee1394" ]]
	then
		if_devname="IEEE1394 (FireWire) Network Adapter";
	fi

	echo ${if_devname}
}

get_ifdesc() {
	local iface=$1
	desc=$(get_ifproduct ${iface})
	if [[ -n ${desc} ]]
	then
		echo $desc
		return;
	fi

	desc=$(get_ifdriver ${iface})
	if [[ -n ${desc} ]]
	then
		echo $desc
		return;
	fi

	desc=$(get_ifmac ${iface})
	if [[ -n ${desc} ]]
	then
		echo $desc
		return;
	fi

	echo "Unknown"
}

show_ifmenu() {
	local old_ifs="${IFS}"
	local opts
	IFS=""
	for ifname in $(/sbin/ifconfig -a | grep "^[^ ]"); do
		ifname="${ifname%% *}"
		[[ ${ifname} == "lo" ]] && continue
		opts="${opts} '${ifname}' '$(get_ifdesc ${ifname})'"
	done
	IFS="${old_ifs}"

	eval dialog --menu \"Please select the interface that you wish to configure from the list below:\" 0 0 0 $opts 2>iface
	[[ "$?" == "1" ]] && exit

	iface=$(< iface)
}

show_ifconfirm() {
	local iface=$1
	local if_mac=$(get_ifmac ${iface})
	local if_driver=$(get_ifdriver ${iface})
	local if_bus=$(get_ifbus ${iface})
	local if_product=$(get_ifproduct ${iface})

	local text="Details for network interface ${iface} are shown below.\n\nInterface name: ${iface}\n"
	[[ -n ${if_product} ]] && text="${text}Device: ${if_product}\n"
	[[ -n ${if_mac} ]] && text="${text}MAC address: ${if_mac}\n"
	[[ -n ${if_driver} ]] && text="${text}Driver: ${if_driver}\n"
	[[ -n ${if_bus} ]] && text="${text}Bus type: ${if_bus}\n"
	text="${text}\nIs this the interface that you wish to configure?"

	if ! dialog --title "Interface details" --yesno "${text}" 15 70
	then
		result="no"
	else
		result="yes"
	fi
}

livecd_console_settings() {
	# scan for a valid baud rate
	case "$1" in
		300*)
			LIVECD_CONSOLE_BAUD=300
		;;
		600*)
			LIVECD_CONSOLE_BAUD=600
		;;
		1200*)
			LIVECD_CONSOLE_BAUD=1200
		;;
		2400*)
			LIVECD_CONSOLE_BAUD=2400
		;;
		4800*)
			LIVECD_CONSOLE_BAUD=4800
		;;
		9600*)
			LIVECD_CONSOLE_BAUD=9600
		;;
		14400*)
			LIVECD_CONSOLE_BAUD=14400
		;;
		19200*)
			LIVECD_CONSOLE_BAUD=19200
		;;
		28800*)
			LIVECD_CONSOLE_BAUD=28800
		;;
		38400*)
			LIVECD_CONSOLE_BAUD=38400
		;;
		57600*)
			LIVECD_CONSOLE_BAUD=57600
		;;
		115200*)
			LIVECD_CONSOLE_BAUD=115200
		;;
	esac
	if [ "${LIVECD_CONSOLE_BAUD}" = "" ]
	then
		# If it's a virtual console, set baud to 38400, if it's a serial
		# console, set it to 9600 (by default anyhow)
		case ${LIVECD_CONSOLE} in 
			tty[0-9])
				LIVECD_CONSOLE_BAUD=38400
			;;
			*)
				LIVECD_CONSOLE_BAUD=9600
			;;
		esac
	fi
	export LIVECD_CONSOLE_BAUD

	# scan for a valid parity
	# If the second to last byte is a [n,e,o] set parity
	local parity
	parity=$(livecd_rev_string $1 | cut -b 2-2)
	case "$parity" in
		[neo])
			LIVECD_CONSOLE_PARITY=$parity
		;;
	esac
	export LIVECD_CONSOLE_PARITY	

	# scan for databits
	# Only set databits if second to last character is parity
	if [ "${LIVECD_CONSOLE_PARITY}" != "" ]
	then
		LIVECD_CONSOLE_DATABITS=$(livecd_rev_string $1 | cut -b 1)
	fi
	export LIVECD_CONSOLE_DATABITS
	return 0
}

livecd_read_commandline() {
	livecd_get_cmdline || return 1

	for x in ${CMDLINE}
	do
		case "${x}" in
			cdroot)
				CDBOOT="yes"
				RC_NO_UMOUNTS="^(/|/dev|/dev/pts|/lib/rcscripts/init.d|/proc|/proc/.*|/sys|/mnt/livecd|/newroot)$"
				export CDBOOT RC_NO_UMOUNTS
			;;
			cdroot\=*)
				CDBOOT="yes"
				RC_NO_UMOUNTS="^(/|/dev|/dev/pts|/lib/rcscripts/init.d|/proc|/proc/.*|/sys|/mnt/livecd|/newroot)$"
				export CDBOOT RC_NO_UMOUNTS
			;;
			console\=*)
				local live_console
				live_console=$(livecd_parse_opt "${x}")

				# Parse the console line. No options specified if
				# no comma
				LIVECD_CONSOLE=$(echo ${live_console} | cut -f1 -d,)
				if [ "${LIVECD_CONSOLE}" = "" ]
				then
					# no options specified
					LIVECD_CONSOLE=${live_console}
				else
					# there are options, we need to parse them
					local livecd_console_opts
					livecd_console_opts=$(echo ${live_console} | cut -f2 -d,)
					livecd_console_settings  ${livecd_console_opts}
				fi
				export LIVECD_CONSOLE
			;;
		esac
	done
	return 0
}

livecd_fix_inittab() {
	if [ "${CDBOOT}" = "" ]
	then
		return 1
	fi

	# Create a backup
	cp -f /etc/inittab /etc/inittab.old

	# Comment out current getty settings
	sed -i -e '/^c[0-9]/ s/^/#/' /etc/inittab
	sed -i -e '/^s[01]/ s/^/#/' /etc/inittab

	# SPARC & HPPA console magic
	if [ "${HOSTTYPE}" = "sparc" -o "${HOSTTYPE}" = "hppa" -o "${HOSTTYPE}" = "ppc64" ]
	then
		# Mount openprom tree for user debugging purposes
		if [ "${HOSTTYPE}" = "sparc" ]
		then
			mount -t openpromfs none /proc/openprom
		fi

		# SPARC serial port A, HPPA mux / serial
		if [ -c "/dev/ttyS0" ]
		then
			LIVECD_CONSOLE_BAUD=$(stty -F /dev/ttyS0 speed)
			echo "s0:12345:respawn:/sbin/agetty -nl /bin/bashlogin ${LIVECD_CONSOLE_BAUD} ttyS0 vt100" >> /etc/inittab
		fi
		# HPPA software PDC console (K-models)
		if [ "${LIVECD_CONSOLE}" = "ttyB0" ]
		then
			mknod /dev/ttyB0 c 11 0
			LIVECD_CONSOLE_BAUD=$(stty -F /dev/ttyB0 speed)
			echo "b0:12345:respawn:/sbin/agetty -nl /bin/bashlogin ${LIVECD_CONSOLE_BAUD} ttyB0 vt100" >> /etc/inittab
		fi
		# FB / STI console
		if [ -c "/dev/vc/1" -o -c "/dev/tts/1" -o -c "/dev/tty2" ]
		then
			MODEL_NAME=$(cat /proc/cpuinfo |grep "model name"|sed 's/.*: //')
			if [ "${MODEL_NAME}" = "UML" ]
			then
			    for x in 0 1 2 3 4 5 6
			    do
				    echo "c${x}:12345:respawn:/sbin/mingetty --noclear --autologin root tty${x}" >> /etc/inittab
			    done
			else
			    for x in 1 2 3 4 5 6
			    do
				    echo "c${x}:12345:respawn:/sbin/mingetty --noclear --autologin root tty${x}" >> /etc/inittab
			    done
			fi
		fi
		if [ -c "/dev/hvc0" ]
		then
			einfo "Adding hvc console to inittab"
			echo "s0:12345:respawn:/sbin/agetty -nl /bin/bashlogin 9600 hvc0 vt320" >> /etc/inittab
		fi


	# The rest...
	else
		for x in 1 2 3 4 5 6
		do
			echo "c${x}:12345:respawn:/sbin/agetty -nl /bin/bashlogin 38400 tty${x} linux" >> /etc/inittab
		done
	fi

	# EFI-based machines should automatically hook up their console lines
	if dmesg | grep -q '^Adding console on'
	then
		dmesg | grep '^Adding console on' | while read x; do
			line=`echo "$x" | cut -d' ' -f4`
			id=e`echo "$line" | grep -o '.\{1,3\}$'`
			[ "${line}" = "${LIVECD_CONSOLE}" ] && continue  # already setup above
			case "$x" in
				*options\ \'[0-9]*) speed=`echo "$x" | sed "s/.*options '//; s/[^0-9].*//"` ;;
				*) speed=9600 ;;  # choose a default, only matters if it is serial
			esac
			echo "$id:12345:respawn:/sbin/agetty -nl /bin/bashlogin ${speed} ${line} vt100" >> /etc/inittab
		done
	fi

	# force reread of inittab
	kill -HUP 1
	return 0
}
