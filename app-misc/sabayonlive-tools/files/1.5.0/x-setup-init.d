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

      is_live=$(cat /proc/cmdline | grep cdroot)
      if [ -n "$is_live" ]; then
          ebegin "Configuring GPU Hardware Acceleration and Input devices"
          start-stop-daemon --start --background --exec /usr/sbin/x-setup-configuration --
          eend 0
      else
          ebegin "Configuring GPU Hardware Acceleration and Input devices"
          if [ -e /first_time_run ] || [ ! -e /etc/gpu-detector.conf ]; then
              # store config file
              lspci | grep ' VGA ' > /etc/gpu-detector.conf
              eend 0
              return 0
          fi

          lspci_vga=$(lspci | grep ' VGA ')
          if [ "$lspci_vga" != "`cat /etc/gpu-detector.conf`" ]; then
              start-stop-daemon --start --background --exec /usr/sbin/x-setup-configuration --
          fi
          eend 0
      fi
}
