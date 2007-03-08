#!/sbin/runscript
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/ipw3945d/files/ipw3945d-init.d,v 1.4 2006/12/22 10:11:26 phreak Exp $

PIDFILE=/var/run/ipw3945d/ipw3945d.pid

depend() {
	before net
}

check() {
	# Let's check if the pidfile is still present.
	if [ -f "${PIDFILE}" ] ; then
		eerror "The pidfile ($PIDFILE) is still present."
		eerror "Please check that the daemon isn't running!"
		return 1
	fi
}

start() {
	IPWAVAIL=$(lspci | grep "Network.*Intel.*3945")
	if [ -n "$IPWAVAIL" ]; then
		check
		ebegin "Starting ipw3945d"
		if [ -e "/sys/bus/pci/drivers/ipw3945" ]; then
			chown ipw3945d /sys/bus/pci/drivers/ipw3945/00*/cmd
			chmod a-w,u+rw /sys/bus/pci/drivers/ipw3945/00*/cmd
		fi
		start-stop-daemon --start --exec /sbin/ipw3945d --pidfile ${PIDFILE} -- \
			--pid-file=${PIDFILE} ${ARGS}
		eend ${?}
	fi
}

stop() {
	ebegin "Stopping ipw3945d"
	start-stop-daemon --stop --exec /sbin/ipw3945d --pidfile ${PIDFILE}
	eend ${?}
}
