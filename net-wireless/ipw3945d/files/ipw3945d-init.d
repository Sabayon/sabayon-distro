#!/sbin/runscript
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/ipw3945d/files/ipw3945d-init.d,v 1.2 2006/09/09 07:53:40 phreak Exp $

PIDFILE=/var/run/ipw3945d/ipw3945d.pid

depend() {
	before net
}

start() {
	ebegin "Starting ipw3945d"
	start-stop-daemon --start --exec /sbin/ipw3945d --pidfile ${PIDFILE} -- \
		--pid-file=${PIDFILE} ${ARGS}
	eend ${?}
}

stop() {
	ebegin "Stopping ipw3945d"
	start-stop-daemon --stop --exec /sbin/ipw3945 --pidfile ${PIDFILE}
	eend ${?}
}
