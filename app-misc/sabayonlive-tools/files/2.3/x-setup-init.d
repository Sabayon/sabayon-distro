#!/sbin/runscript
# Copyright 2009-2012 Fabio Erculiani - Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

depend() {
    after mtab
    before hostname
    before xdm
}

gpus_same() {
    # $1 and $2: output lines from "lspci"
    local id1 id2 # [xxxx:]xx:xx.x
    local dev1 dev2 # vendor and device: xxxx:xxxx
    id1=$(echo "$1" | awk '/ VGA / { print $1 }')
    id2=$(echo "$2" | awk '/ VGA / { print $1 }')
    if [ -z "$id1" ] || [ -z "$id2" ]; then
        return 1
    fi
    dev1=$(lspci -s "$id1" -n | awk '{ print $3 }')
    dev2=$(lspci -s "$id2" -n | awk '{ print $3 }')
    [ "$dev1" = "$dev2" ]
}

start() {
    . /sbin/sabayon-functions.sh
    local do_redetect
    do_redetect=$(cat /proc/cmdline | grep "gpudetect")

    if sabayon_is_live; then
        ebegin "Configuring GPU Hardware Acceleration and Input devices"
        start-stop-daemon --start --background --pidfile /var/run/x-setup.pid --make-pidfile --exec /usr/sbin/x-setup-configuration
        eend 0
    else
        if [ -e /first_time_run ] || [ ! -e /etc/gpu-detector.conf ] \
          || [ -n "$do_redetect" ] || [ ! -f /etc/X11/xorg.conf ]; then
            ebegin "Configuring GPU Hardware Acceleration and Input devices for the first time"
            # store config file
            lspci | grep ' VGA ' > /etc/gpu-detector.conf
            /usr/sbin/x-setup-configuration
            eend 0
            return
        fi

        local lspci_vga stored_vga
        local infostr_run="Configuring GPU Hardware Acceleration and Input devices"
        local infostr_skip="Skipping GPU Hardware Acceleration and Input devices configuration"
        lspci_vga=$(lspci | grep ' VGA ')
        stored_vga=$(cat /etc/gpu-detector.conf)

        if [ "$lspci_vga" != "$stored_vga" ] ;  then
            # Strings are different, let's do the more "heavy" and accurate comparison.
            if gpus_same "$lspci_vga" "$stored_vga"; then
                # this may happen after vendor changes its name etc. and PCI ID file is updated
                ebegin "${infostr_skip}, only updating GPU information file"
            else
                ebegin "$infostr_run"
                /usr/sbin/x-setup-configuration &> /dev/null
            fi

            echo "$lspci_vga" > /etc/gpu-detector.conf
            eend 0
            return
        fi

        einfo "$infostr_skip"
    fi
}
