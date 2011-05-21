# /lib/rcscripts/addons/raid-start.sh:  Setup raid volumes at boot
# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/mdadm/files/raid-start.sh-3.0,v 1.2 2010/06/03 02:03:40 vapier Exp $

[ -f /proc/mdstat ] || exit 0

# Start software raid with mdadm
if [ -x /sbin/mdadm ] ; then
	ebegin "Starting up RAID devices"
	output=$(mdadm -As 2>&1)
	ret=$?
	[ ${ret} -ne 0 ] && echo "${output}"
	eend ${ret}
fi

if [ -x /sbin/blockdev ] ; then
	partitioned_devs=$(ls /dev/md_d* 2>/dev/null)
	if [ -n "${partitioned_devs}" ]; then
		ebegin "Creating RAID device partitions"
		/sbin/blockdev ${partitioned_devs}
		eend 0
		# wait because vgscan runs next, and we want udev to fire
		sleep 1
	fi
fi

# vim:ts=4
