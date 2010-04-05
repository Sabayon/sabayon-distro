#!/bin/bash

# Script to read EDD information from sysfs and
# echo the FCoE interface name and target info.
# This is a work in progress and will be enhanced
# with more options as we progress further.
#
# Author: Supreeth Venkataraman
#	  Yi Zou
#         Intel Corporation
#
# Usage: sysfs_edd.sh -t for getting FCoE boot target information.
#        sysfs_edd.sh -i for getting FCoE boot NIC name.
#        sysfs_edd.sh -m for getting FCoE boot NIC MAC.
#        sysfs_edd.sh -e for getting FCoE boot EDD information.
#        sysfs_edd.sh -r for getting FCoE boot EDD interface type and path.
#        sysfs_edd.sh -a for getting all FCoE boot information.
#        sysfs_edd.sh -h for usage information.
#        Optional: use -v to turn on verbose mode.
#
# Notes:
# FCoE Boot Disk is identified by the following format of boot information
# in its corresponding sysfs firmware edd entry, i.e.,
# 	/sys/firmware/edd/int13_dev??/interface
# which is formatted as (for FCoE):
# string format: FIBRE wwid: 8c1342b8a0001620 lun: 7f00
# Please ref. to T13 BIOS Enhanced Disk Drive Specification v3.0 for more
# defails on EDD.
#

SYSEDD=/sys/firmware/edd
PREFIX="FIBRE"
VERBOSE=
FCOE_INF=
FCOE_WWN=
FCOE_LUN=
FCOE_EDD=
FCOE_NIC=
FCOE_MAC=


#
#
#
LOG() {
	if [ -n "$1" ] && [ -n "${VERBOSE}" ]; then
		echo "LOG:$1"
	fi
}


find_fcoe_boot_disk() {
	local prefix=

	if [ ! -e $SYSEDD ]; then
		LOG "Need kernel EDD support!"
		return 1
	fi
#	for disk in `find ${SYSEDD} -maxdepth 1 -name 'int13*'`
	for disk in ${SYSEDD}/int13_*
	do
		LOG " checking $disk..."
		if [ ! -e ${disk}/interface ]; then
			continue;
		fi
		LOG " checking ${disk}/interface..."
		prefix=`awk '{printf $1}' < ${disk}/interface`
		if [ "${PREFIX}" != "${prefix}" ]; then
			LOG " The FCoE Boot prefix ${FCOE_PRE} is invalid!"
			continue;
		fi
		FCOE_INF=`cat ${disk}/interface`
		LOG " found FCoE boot info. from boot rom:${FCOE_INF}..."

	 	FCOE_WWN=`awk '{printf $3}' < ${disk}/interface`
		if [ ${#FCOE_WWN} -ne 16 ]; then
			LOG " The FCoE Boot WWID ${FCOE_WWN} is invalid!"
			continue;
		fi
		FCOE_LUN=`awk '{printf $5}' < ${disk}/interface`
		if [ -z "${#FCOE_LUN}" ]; then
			LOG " The FCoE Boot LUN ${FCOE_WWN} is invalid!"
			continue;
		fi
		# look for the correponding nic
		# FIXME:
		# 1) only supporst PCI device? 
		# 2) at initrd time, the nic name is always eth*? 
		if [ ! -e ${disk}/pci_dev ]; then
			LOG "Failed to locate the corresponing PCI device!"
			continue;
		fi
		if [ ! -e ${disk}/pci_dev/net ]; then
			LOG "Failed to detect any NIC device!"
			continue;
		fi
		
		for nic in ${disk}/pci_dev/net/*
		do
			if [ -e ${nic}/address ]; then
				FCOE_MAC=`cat ${nic}/address`
				FCOE_NIC=$(basename ${nic})
				break;
			fi
		done
		if [ -z "${FCOE_MAC}" ] || [ -z "${FCOE_NIC}" ]; then
			LOG "Failed to locate the corresponing NIC device!"
			continue;
		fi
		# Found the FCoE Boot Device
		FCOE_EDD=$(basename ${disk})
		return 0;
	done
	return 1
}

get_fcoe_boot_all(){
	echo "### FCoE Boot Information ###"
	echo "EDD=${FCOE_EDD}"
	echo "INF=${FCOE_INF}"
	echo "WWN=${FCOE_WWN}"
	echo "LUN=${FCOE_LUN}"
	echo "NIC=${FCOE_NIC}"
	echo "MAC=${FCOE_MAC}"
	return 0
}

get_fcoe_boot_target() {
	if [ -z "${FCOE_WWN}" ] || [ -z "${FCOE_LUN}" ]; then
		LOG "No FCoE Boot Target information is found!"
		return 1
	fi
	echo "WWN=${FCOE_WWN}"
	echo "LUN=${FCOE_LUN}"
}

get_fcoe_boot_inf(){
	if [ -z "${FCOE_INF}" ]; then
		LOG "No FCoE Boot INF information is found!"
		return 1
	fi
	echo "INF=${FCOE_INF}"
	return 0
}

get_fcoe_boot_mac(){
	if [ -z "${FCOE_MAC}" ]; then
		LOG "No FCoE Boot NIC MAC information is found!"
		return 1
	fi
	echo "MAC=${FCOE_MAC}"
	return 0
}

get_fcoe_boot_ifname(){
	if [ -z "${FCOE_NIC}" ]; then
		LOG "No FCoE Boot NIC information is found!"
		return 1
	fi
	echo "NIC=${FCOE_NIC}"
	return 0
}

get_fcoe_boot_edd(){
	if [ -z "${FCOE_EDD}" ]; then
		LOG "No FCoE Boot Disk EDD information is found!"
		return 1
	fi
	echo "EDD=${FCOE_EDD}"
	return 0
}


# parse options
prog=$(basename $0)
while getopts "timeravh" OptionName; do
    case "$OptionName" in
        t) 
		action=get_fcoe_boot_target
		;;
        i)
		action=get_fcoe_boot_ifname
		;;
        m)
		action=get_fcoe_boot_mac
		;;
        e)
		action=get_fcoe_boot_edd
		;;
        r)
		action=get_fcoe_boot_inf
		;;
	a)
		action=get_fcoe_boot_all
		;;
	v)
		VERBOSE="yes"
		;;
        h)
		echo "Usage: ${prog} -t for getting FCoE boot target information."
		echo "       ${prog} -i for getting FCoE boot NIC name."
		echo "       ${prog} -m for getting FCoE boot NIC MAC."
		echo "       ${prog} -e for getting FCoE boot EDD information."
		echo "       ${prog} -r for getting FCoE boot EDD interface type and path."
		echo "       ${prog} -a for getting all FCoE boot information."
		echo "       ${prog} -h for usage information."
		echo "       Optional: use -v to turn on verbose mode."
		exit 0
		;;
        *)
		echo "Invalid Option. Use -h option for help."
		exit 1
		;;
    esac
done
if [ -z "${action}" ]; then
	echo "Must specify at least -t, -i, -m, -e, -r, -a, or -h."
	echo "Use -h option for help."
	exit 1
fi
# Locate FCoE boot disk and nic information
find_fcoe_boot_disk
if [ $? -ne 0 ]; then
	echo "No FCoE boot disk information is found in EDD!"
	exit 1
fi
if [ -z "${FCOE_EDD}" ]; then
	echo "No FCoE boot disk is found in EDD!"
	exit 1;
fi

${action}

exit $?
