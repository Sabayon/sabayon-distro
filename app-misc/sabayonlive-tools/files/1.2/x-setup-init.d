#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

depend() {
	before acpid
	after internetkiosk
}


start() {

      ebegin "Configuring GPUs and Hardware Acceleration"

      # Fixing things (here for now)
      if [ ! -e /var/cache/edb ]; then
	mkdir /var/cache/edb
	mkdir /var/cache/edb/dep
	chmod 775 /var/cache/edb -R
	chmod 775 /var/cache/edb/dep -R
	chown root:portage /var/cache/edb -R
      fi

      # create seed
      rm -f /etc/x-setup-configuration-running
      touch /etc/x-setup-configuration-running

      
      # Start-up x-setup-configuration
      /sbin/x-setup-configuration &> /dev/null &

      # create seed
      rm -f /etc/x-setup-configuration-running

      eend 0
}