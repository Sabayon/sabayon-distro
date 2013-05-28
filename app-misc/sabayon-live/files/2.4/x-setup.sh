#!/bin/bash

. /sbin/sabayon-functions.sh

REDETECT=$(cat /proc/cmdline | grep "gpudetect")

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


if [ -e /first_time_run ] || [ ! -e /etc/gpu-detector.conf ] \
    || [ -n "${REDETECT}" ]; then
    echo "Configuring GPUs and input devices for the first time"
    lspci | grep ' VGA ' > /etc/gpu-detector.conf
    /usr/sbin/x-setup-configuration
    exit 0
fi

infostr_run="Configuring GPUs and input devices"
infostr_skip="Skipping GPUs and input devices configuration"
lspci_vga=$(lspci | grep ' VGA ')
stored_vga=$(cat /etc/gpu-detector.conf)

if [ "${lspci_vga}" != "${stored_vga}" ]; then
    # Strings are different, let's do the more "heavy" and accurate comparison.
    if gpus_same "${lspci_vga}" "${stored_vga}"; then
        # this may happen after vendor changes its name etc.
        # and PCI ID file is updated
        echo "${infostr_skip}, only updating GPU information file"
    else
        echo "${infostr_run}"
        /usr/sbin/x-setup-configuration
    fi
    echo "${lspci_vga}" > /etc/gpu-detector.conf
    exit 0
fi

echo "${infostr_skip}"
