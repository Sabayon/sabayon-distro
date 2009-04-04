#!/sbin/runscript
# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/files/4.18/bluetooth-init.d,v 1.1 2008/11/28 21:21:35 dev-zero Exp $

depend() {
	after coldplug
	need dbus localmount
}

start() {
   	ebegin "Starting Bluetooth"
	local result=0

	ebegin "    Starting bluetoothd"
	# -s enables internal sdp server
	start-stop-daemon --start \
		--exec /usr/sbin/bluetoothd
	result=$?
	eend ${result}

	if [ "${HID2HCI_ENABLE}" = "true" -a -x /usr/sbin/hid2hci ]; then
		ebegin "    Running hid2hci"
		/usr/sbin/hid2hci --tohci -q    #be quiet
		[ ${result} == 0 ] && result=$?
		eend ${result}
	fi

	if [ "${RFCOMM_ENABLE}" = "true" -a -x /usr/bin/rfcomm ]; then
		if [ -f "${RFCOMM_CONFIG}" ]; then
			ebegin "    Starting rfcomm"
			/usr/bin/rfcomm -f "${RFCOMM_CONFIG}" bind all
			[ ${result} == 0 ] && result=$?
			eend ${result}
		else
			ewarn "Not enabling rfcomm because RFCOMM_CONFIG does not exists"
		fi
	fi

	eend ${result}
}

stop() {
	ebegin "Shutting down Bluetooth"

	start-stop-daemon --stop --quiet --exec /usr/sbin/bluetoothd
	eend $?
}
