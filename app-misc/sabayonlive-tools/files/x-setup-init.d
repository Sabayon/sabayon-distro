#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo/src/livecd-tools/x-setup.init,v 1.3 2005/03/01 18:13:51 wolf31o2 Exp $

depend() {
	before xdm local
}

start() {

      # get livecd functions
      source /sbin/livecd-functions.sh

      if [ ! -e /var/cache/edb ]; then
	mkdir /var/cache/edb
	mkdir /var/cache/edb/dep
	chmod 775 /var/cache/edb -R
	chmod 775 /var/cache/edb/dep -R
	chown root:portage /var/cache/edb -R
      fi

      cmdline_onlyvesa_exist=$(cat /proc/cmdline | grep onlyvesa)
      cmdline_noproprietary_exist=$(cat /proc/cmdline | grep noproprietary)

      if [ -n "$cmdline_onlyvesa_exist" ]; then

	return 0
	eend 0

      else

	xen_exists=$(/bin/uname -a | grep 2.6.*-xen*)

	if [ -n "$cmdline_noproprietary_exist" ] || [ -n "$xen_exists" ]; then

		ebegin "OpenGL already configured"
		eend 0

	else

	  cmdline_opengl_exists=$(cat /proc/cmdline | grep "opengl=")
	  if [ -n "$cmdline_opengl_exists" ]; then

             for word in `cat /proc/cmdline` ; do
                case $word in
                  opengl=*)
                         opengl_toset=$(echo $word | cut -d "=" -f 2)
                	 ebegin "Configuring OpenGL for "$opengl_toset
        	         /usr/bin/eselect opengl set --dst-prefix=/etc/opengl $opengl_toset
	                 eend $?
                  ;;
                esac
              done


	  else

		 get_video_cards &> /dev/null
		 get_current_gl=$(eselect opengl show)

                # Fix for "nVidia Corporation Unknown device"
                if [ -n "`lspci | grep VGA | grep 'nVidia Corporation Unknown device'`" ]; then
                  ebegin "Configuring OpenGL (Unknown nVidia device)"
                  /usr/bin/eselect opengl set --dst-prefix=/etc/opengl nvidia
                  eend $?
                fi

                # Fix for "nVidia Corporation PCI Express Device"
                if [ -n "`lspci | grep VGA | grep nVidia | grep 'PCI Express'`" ]; then
                  ebegin "Configuring OpenGL (PCI Express device)"
                  /usr/bin/eselect opengl set --dst-prefix=/etc/opengl nvidia
                  eend $?
                fi

                # Fix for "ATI Technologies .* RV350"
                if [ -n "`lspci | grep VGA | grep 'ATI Technologies .* RV350'`" ]; then
                  ebegin "Configuring OpenGL (ATI Radeon 9600)"
                  eend $?
                fi

	
	        if [ "$get_current_gl" != "$GLTYPE" ]; then
		  ebegin "Configuring OpenGL"
		  /usr/sbin/x-setup
		  eend $?
		else
		  ebegin "OpenGL already configured"
		  eend 0
		fi
	
 	  fi

	fi

     fi
}
