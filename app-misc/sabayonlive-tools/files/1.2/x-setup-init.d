#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

depend() {
	before acpid
	after internetkiosk
}

configure_opengl() {

if [ -n "$cmdline_opengl_exists" ]; then
   for word in `cat /proc/cmdline` ; do
      case $word in
         opengl=*)
            opengl_toset=$(echo $word | cut -d "=" -f 2)
            /usr/bin/eselect opengl set --dst-prefix=/etc/opengl $opengl_toset
            ;;
      esac
   done
else
   get_video_cards &> /dev/null
   get_current_gl=$(eselect opengl show)

   # Fix for "nVidia Corporation Unknown device"
   if [ -n "`lspci | grep VGA | grep 'nVidia Corporation Unknown device'`" ]; then
      /usr/bin/eselect opengl set --dst-prefix=/etc/opengl nvidia
   elif [ -n "`lspci | grep VGA | grep nVidia | grep 'PCI Express'`" ]; then
      # Fix for "nVidia Corporation PCI Express Device"
      /usr/bin/eselect opengl set --dst-prefix=/etc/opengl nvidia
   else
      if [ "$get_current_gl" != "$GLTYPE" ]; then
         /usr/sbin/x-setup
      fi
   fi
fi

}

runtime_linking_proprietary_drivers() {

   mount -t tmpfs none /lib/modules/$(uname -r)/video
   current_arch=$(uname -m)
   if [ "$current_arch" == "x86_64" ]; then
      ld_arch="elf_x86_64"
   elif [ "$current_arch" == "i686" ]; then
      ld_arch="elf_i386"
   fi
   ld -m $ld_arch -r -o /lib/modules/$(uname -r)/video/nvidia.ko /lib/nvidia/nvidia.o /lib/nvidia/nvidia.mod.o
   ld -m $ld_arch -r -o /lib/modules/$(uname -r)/video/fglrx.ko /lib/fglrx/fglrx.o /lib/fglrx/fglrx.mod.o

}

configure_read_write_paths() {

   # if it's not already mounted, mount KDM config r/w
   kdm_is_mounted=$(cat /etc/mtab | grep kdm )
   if [ -z "$kdm_is_mounted" ]; then
      # mount it !
      mkdir /tmp/kdm
      cp /usr/kde/3.5/share/config/kdm/* /tmp/kdm/ -Rp
      mount -t tmpfs none /usr/kde/3.5/share/config/kdm/
      cp /tmp/kdm/* /usr/kde/3.5/share/config/kdm/ -Rp
      rm -rf /tmp/kdm
   fi

   # Fix .ICE-unix permissions
   mkdir -m 1777 /tmp/.ICE-unix -p
   chown root /tmp/.ICE-unix
   chown root /tmp/.ICE-unix -R
   chmod 1777 /tmp/.ICE-unix

}

start_acceleration_manager() {

   # Configure XGL ?
   if [ -n "$cmdline_xgl_exist" ]; then
      #echo -en "\E[33;36m * \E[0m \E[01;32m Configuring the system for XGL... \E[0m"
      /sbin/xgl-setup enable &> /dev/null
      #echo -e "Done"
   fi

   # Configure AIGLX ?
   if [ -n "$cmdline_aiglx_exist" ] && [ -z "$cmdline_xgl_exist" ]; then
      #echo -en "\E[33;36m * \E[0m \E[01;32m Configuring the system for AIGLX... \E[0m"
      /sbin/aiglx-setup enable &> /dev/null
      #echo -e "Done"
   fi

   # Start-up accel-manager - this must be always after gpu-configuration
   if [ -z "$cmdline_noaccelmanager_exist" ] && [ -z "$cmdline_xgl_exist" ] && [ -z "$cmdline_aiglx_exist" ]; then
      # ok, no xgl,aiglx and noaccelmanager parameters at boot. start the app
      /usr/share/accel-manager/desktop-accel-selector &> /dev/null &
   fi

}

configure_video_settings() {

   # X.Org must be started and now I'm checking if user wants to start the server at 640x480
   if [ -n "$cmdline_legacy_exist" ]; then
      mv -f /etc/X11/xorg.conf.legacy /etc/X11/xorg.conf
      /sbin/gpu-configuration &> /dev/null
      #echo -e "\E[33;36m * \E[0m \E[01;32m Starting up X.Org in (- Legacy -) mode ::\E[0m"
      #echo -e "\t Display Configuration: 800x600 at 60Hz"
   else
      if [ -n "$cmdline_resolution_forced" ];then
         # change resolution in X.Org
         for word in `cat /proc/cmdline` ; do
            case $word in
               res=*)
                  resolution_toset=$(echo $word | cut -d "=" -f 2)
		  if [ "$resolution_toset" == "800x600" ]; then
                     execute_cmd="sed -i '/Modes/ s/\"1024x768\"/\"$resolution_toset\"/' /etc/X11/xorg.conf"
		  elif [ "$resolution_toset" == "640x480" ]; then
                     execute_cmd="sed -i '/Modes/ s/\"1024x768\"/\"$resolution_toset\"/' /etc/X11/xorg.conf"
		  else
                     execute_cmd="sed -i '/Modes/ s/\"1024x768\"/\"$resolution_toset\" \"1024x768\"/' /etc/X11/xorg.conf"
		  fi
                  echo $execute_cmd | /bin/bash
                  #echo -e "\E[33;36m * \E[0m\E[01;32m Setting X.Org to $resolution_toset if it's available \E[0m"
		  sed -i '/Modes/ s/#//g' /etc/X11/xorg.conf
               ;;
            esac
         done
      fi

      # Check if refresh= is forced by cmdline
      if [ -n "$cmdline_refresh_exist" ];then
	 # change VertRefresh in X.Org
         for word in `cat /proc/cmdline` ; do
            case $word in
               refresh=*)
		  sed -i '/VertRefresh/ s/#//g' /etc/X11/xorg.conf
                  refresh_toset=$(echo $word | cut -d "=" -f 2)
                  execute_cmd="sed -i '/VertRefresh/ s/.*/    VertRefresh $refresh_toset/' /etc/X11/xorg.conf"
	          echo $execute_cmd | /bin/bash
		  #echo -e "\E[33;36m * \E[0m\E[01;32m Setting VertRefresh to $refresh_toset Hz \E[0m"
               ;;
            esac
         done
      fi

      # Check if refresh= is forced by cmdline
      if [ -n "$cmdline_hsync_exist" ];then
         # change HorizSync in X.Org
         for word in `cat /proc/cmdline` ; do
            case $word in
               hsync=*)
                  sed -i '/HorizSync/ s/#//g' /etc/X11/xorg.conf
                  hsync_toset=$(echo $word | cut -d "=" -f 2)
                  execute_cmd="sed -i '/HorizSync/ s/.*/    HorizSync $hsync_toset/' /etc/X11/xorg.conf"
                  echo $execute_cmd | /bin/bash
                  #echo -e "\E[33;36m * \E[0m\E[01;32m Setting HorizSync to $hsync_toset Hz \E[0m"
               ;;
            esac
         done
      fi


      if [ -z "$cmdline_onlyvesa_exist" ]; then
	 #echo -e "\E[33;36m * \E[0m\E[01;32m  Video Card:`lspci | grep VGA | cut -d: -f3` \E[0m"
         /sbin/gpu-configuration &> /dev/null
      fi

}

start() {

      ebegin "Configuring GPUs and Hardware Acceleration"

      # get livecd functions
      source /sbin/livecd-functions.sh

      # Fixing things (here for now)
      if [ ! -e /var/cache/edb ]; then
	mkdir /var/cache/edb
	mkdir /var/cache/edb/dep
	chmod 775 /var/cache/edb -R
	chmod 775 /var/cache/edb/dep -R
	chown root:portage /var/cache/edb -R
      fi

      # Cleaning files
      rm -f /etc/accel-manager-running

      # Variables
      cmdline_onlyvesa_exist=$(cat /proc/cmdline | grep onlyvesa)
      cmdline_noproprietary_exist=$(cat /proc/cmdline | grep noproprietary)
      cmdline_opengl_exists=$(cat /proc/cmdline | grep "opengl=")
      cmdline_noxorg_exist=$(cat /proc/cmdline | grep nox)
      cmdline_fastboot_exist=$(cat /proc/cmdline | grep fastboot)
      cmdline_kiosk_exist=$(cat /proc/cmdline | grep internetkiosk)
      cmdline_legacy_exist=$(cat /proc/cmdline | grep legacy)
      cmdline_resolution_forced=$(cat /proc/cmdline | grep "res=")
      cmdline_refresh_exist=$(cat /proc/cmdline | grep refresh=)
      cmdline_hsync_exist=$(cat /proc/cmdline | grep hsync=)
      cmdline_xgl_exist=$(cat /proc/cmdline | grep " xgl")
      cmdline_aiglx_exist=$(cat /proc/cmdline | grep " aiglx")
      cmdline_noaccelmanager_exist=$(cat /proc/cmdline | grep "noaccelmanager")

      # Prepare OpenGL
      if [ -z "$cmdline_onlyvesa_exist" ] && [ -z "$cmdline_noproprietary_exist" ]; then
         configure_opengl
      fi
      
      # Prepare Video Cards Proprietary Drivers
      runtime_linking_proprietary_drivers

      # Configure Video Card Driver
      configure_video_settings

      # Configure read/write paths
      configure_read_write_paths

      # Start-up Desktop Acceleration Configurator
      start_acceleration_manager

      eend 0
}
