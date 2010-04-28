#!/sbin/runscript
# Copyright 2009 Fabio Erculiani - Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

depend() {
    after mtab
    before hostname
    before xdm
}


start() {

    is_live=$(cat /proc/cmdline | grep "cdroot")
    do_redetect=$(cat /proc/cmdline | grep "gpudetect")
    if [ -n "$is_live" ]; then
        ebegin "Configuring GPU Hardware Acceleration and Input devices"
        start-stop-daemon --start --background --pidfile /var/run/x-setup.pid --make-pidfile --exec /usr/sbin/x-setup-configuration
        eend 0
    else
        ebegin "Configuring GPU Hardware Acceleration and Input devices for the first time"
        if [ -e /first_time_run ] || [ ! -e /etc/gpu-detector.conf ] || [ -n "$do_redetect" ]; then
            # store config file
            lspci | grep ' VGA ' > /etc/gpu-detector.conf
            /usr/sbin/x-setup-configuration
            eend 0
            return 0
        fi

        lspci_vga=$(lspci | grep ' VGA ')
        if [ "$lspci_vga" != "`cat /etc/gpu-detector.conf`" ] || [ ! -f /etc/X11/xorg.conf ]; then
            /usr/sbin/x-setup-configuration &> /dev/null
            lspci | grep ' VGA ' > /etc/gpu-detector.conf
        fi
        eend 0
    fi

}
