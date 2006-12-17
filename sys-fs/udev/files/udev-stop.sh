# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

main() {
	if [[ -e /dev/.devfsd || ! -e /dev/.udev || ! -z ${CDBOOT} || \
	   ${RC_DEVICE_TARBALL} != "yes" ]] || \
	   ! touch /lib/udev-state/devices.tar.bz2 2>/dev/null
	then
		return 0
	fi
		
	ebegin "Saving device nodes"
	# Handle our temp files
	devices_udev=$(mktemp /tmp/devices.udev.XXXXXX)
	devices_real=$(mktemp /tmp/devices.real.XXXXXX)
	devices_totar=$(mktemp /tmp/devices.totar.XXXXXX)
	device_tarball=$(mktemp /tmp/devices-XXXXXX)
	
	if [[ -z ${devices_udev} || -z ${devices_real} || \
	      -z ${devices_totar} || -z ${device_tarball} ]] ; then
		eend 1 "Could not create temporary files!"
	else
		cd /dev
		# Find all devices
		find . -xdev -type b -or -type c -or -type l | cut -d/ -f2- > \
			"${devices_real}"
		# Figure out what udev created
		eval $(grep '^[[:space:]]*udev_db=' /etc/udev/udev.conf)
		if [[ -d ${udev_db} ]]; then
			# New udev_db is clear text ...
			udevinfo=$(cat "${udev_db}"/*)
		else
			# Old one is not ...
			udevinfo=$(udevinfo -d)
		fi
		# This basically strips 'S:' and 'N:' from the db output, and then
		# print all the nodes/symlinks udev created ...
		echo "${udevinfo}" | gawk '
			/^(N|S):.+/ {
				sub(/^(N|S):/, "")
				split($0, nodes)
				for (x in nodes)
					print nodes[x]
			}' > "${devices_udev}"
		# These ones we also do not want in there
		for x in MAKEDEV core fd initctl pts shm stderr stdin stdout; do
			echo "${x}" >> "${devices_udev}"
		done
		fgrep -x -v -f "${devices_udev}" < "${devices_real}" > "${devices_totar}"
		# Now only tarball those not created by udev if we have any
		if [[ -s ${devices_totar} ]]; then
			# we dont want to descend into mounted filesystems (e.g. devpts)
			# looking up username may involve NIS/network, and net may be down
			tar --one-file-system --numeric-owner -jcpf "${device_tarball}" -T "${devices_totar}"
			mv -f "${device_tarball}" /lib/udev-state/devices.tar.bz2
		else
			rm -f /lib/udev-state/devices.tar.bz2
		fi
		eend 0
	fi

	rm -f "${devices_udev}" "${devices_real}" "${devices_totar}" "${device_tarball}"
}

main


# vim:ts=4
