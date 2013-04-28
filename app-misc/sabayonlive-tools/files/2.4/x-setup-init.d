#!/sbin/runscript
# Copyright 2009-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2

depend() {
    after mtab
    before hostname
    before xdm
}



start() {
    . /sbin/sabayon-functions.sh

    ebegin "Configuring GPUs and input devices"
    if sabayon_is_live; then
        start-stop-daemon --start --background --pidfile /var/run/x-setup.pid \
            --make-pidfile --exec /usr/sbin/x-setup-configuration
        eend 0
        return 0
    fi

    /usr/libexec/x-setup.sh > /dev/null
    eend ${?}
}
