#!/bin/bash

SABAYON_USER="sabayonmce"
. /sbin/sabayon-functions.sh

if sabayon_is_mce; then
    echo "Sabayon Media Center mode enabled"

    echo "[Desktop]" > /var/sabayonmce/.dmrc
    echo "Session=sabayon-mce" >> /var/sabayonmce/.dmrc
    chown sabayonmce /var/sabayonmce/.dmrc

    if [ -x "/usr/libexec/gdm-set-session" ]; then
        /usr/libexec/gdm-set-session sabayonmce sabayon-mce
    fi
    sabayon_setup_autologin

elif ! sabayon_is_live && ! sabayon_is_mce; then
    echo "Sabayon Media Center mode disabled"
    sabayon_disable_autologin
fi

exit 0
