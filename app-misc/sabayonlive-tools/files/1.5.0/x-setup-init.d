#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

depend() {
	before hostname
	before xdm
	after internetkiosk
}


start() {

      ebegin "Configuring GPU Hardware Acceleration and Input devices"

      # Start-up x-setup-configuration
      start-stop-daemon --start --background --exec /usr/sbin/x-setup-configuration --

      eend 0
}
