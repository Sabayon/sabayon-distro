#!/bin/bash

is_live=$(cat /proc/cmdline | grep cdroot)

if [ -n "${is_live}" ]; then
    cdrom_dev=$(cat /proc/mounts | grep " /mnt/cdrom " | cut -d" " -f 1)
    # check if /mnt/cdrom device is a cdrom device
    if [ "${cdrom_dev}" = /dev/sr* ] || [ "${cdrom_dev}" = /dev/cdrom* ]; then
        eject -mp "${cdrom_dev}" &> /dev/null
    fi
fi

