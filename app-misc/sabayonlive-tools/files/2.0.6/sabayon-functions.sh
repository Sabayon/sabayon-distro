#!/bin/bash

sabayon_setup_autologin() {

        # GDM - GNOME
	if [ -f "/usr/share/gdm/defaults.conf" ]; then
	        sed -i 's/^AutomaticLoginEnable=.*/AutomaticLoginEnable=true/' /usr/share/gdm/defaults.conf
        	sed -i 's/^AutomaticLogin=.*/AutomaticLogin=sabayonuser/' /usr/share/gdm/defaults.conf
	fi

        # KDM - KDE
        for kver in `ls /usr/kde`; do

                kdm_file="/usr/kde/${kver}/share/config/kdm/kdmrc"
                if [ ! -f "$kdm_file" ]; then
                        continue
                fi

                sed -i 's/AutoLoginEnable=.*/AutoLoginEnable=true/' $kdm_file
                sed -i 's/AutoLoginUser=.*/AutoLoginUser=sabayonuser/' $kdm_file
                sed -i 's/AutoLoginDelay=.*/AutoLoginDelay=0/' $kdm_file

                sed -i '/^#.*AutoLoginEnable=/ s/^#//' $kdm_file
                sed -i '/^#.*AutoLoginUser=/ s/^#//' $kdm_file
                sed -i '/^#.*AutoLoginDelay=/ s/^#//' $kdm_file

        done


}

sabayon_setup_motd() {
	echo -e "\n\tWelcome to `cat /etc/sabayon-edition`\n\t`uname -p`\n\t`uname -o` `uname -r`\n" > /etc/motd
}

sabayon_setup_vt_autologin() {
	source /sbin/livecd-functions.sh
	export CDBOOT=1
	livecd_fix_inittab
}

sabayon_setup_md_devices() {
	for i in 0 1 2 3 4 5 6 7 8 9 10; do
		mknod /dev/md$i b 9 $i &> /dev/null
	done
}
