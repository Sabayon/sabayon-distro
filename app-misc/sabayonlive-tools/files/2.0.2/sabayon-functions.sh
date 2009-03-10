#!/bin/bash

sabayon_setup_autologin() {

        # GDM - GNOME
        sed -i 's/^AutomaticLoginEnable=.*/AutomaticLoginEnable=true/' /usr/share/gdm/defaults.conf
        sed -i 's/^AutomaticLogin=.*/AutomaticLogin=sabayonuser/' /usr/share/gdm/defaults.conf

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
