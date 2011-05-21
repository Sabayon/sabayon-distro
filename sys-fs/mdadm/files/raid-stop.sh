# /lib/rcscripts/addons/raid-stop.sh:  Stop raid volumes at shutdown
# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/mdadm/files/raid-stop.sh,v 1.4 2008/06/28 16:36:46 vapier Exp $

[ -f /proc/mdstat ] || exit 0

# Stop software raid with mdadm (new school)
mdadm_conf="/etc/mdadm/mdadm.conf"
[ -e /etc/mdadm.conf ] && mdadm_conf="/etc/mdadm.conf"
if [ -x /sbin/mdadm -a -f "${mdadm_conf}" ] ; then
	ebegin "Shutting down RAID devices (mdadm)"
	output=$(mdadm -Ss 2>&1)
	ret=$?
	[ ${ret} -ne 0 ] && echo "${output}"
	eend ${ret}
fi

# vim:ts=4
