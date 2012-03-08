#!/sbin/runscript

depend() {
	use net
	@neededservices@
	before nfs
	after logger
}

start() {
	ebegin "Starting cupsd"
	checkpath -q -d -m 0755 -o root:lp /var/run/cups
	checkpath -q -d -m 0511 -o lp:lpadmin /var/run/cups/certs
	start-stop-daemon --start --quiet --exec /usr/sbin/cupsd
	eend $?
}

stop() {
	ebegin "Stopping cupsd"
	start-stop-daemon --stop --quiet --exec /usr/sbin/cupsd
	eend $?
}
