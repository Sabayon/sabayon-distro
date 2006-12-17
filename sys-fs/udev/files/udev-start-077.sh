# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

udev_version() {
	local version=0

	if [[ -x /sbin/udev ]] ; then
		version=$(/sbin/udev -V)
		# We need it without a leading '0', else bash do the wrong thing
		version=${version##0}
		# Older udev's will print nothing
		[[ -z ${version} ]] && version=0
	fi

	echo "${version}"
}

populate_udev() {
	# Now populate /dev
	/sbin/udevstart

	# Not provided by sysfs but needed
	ln -snf /proc/self/fd /dev/fd
	ln -snf fd/0 /dev/stdin
	ln -snf fd/1 /dev/stdout
	ln -snf fd/2 /dev/stderr
	[[ -e /proc/kcore ]] && ln -snf /proc/kcore /dev/core

	# Create nodes that udev can't
	[[ -x /sbin/dmsetup ]] && /sbin/dmsetup mknodes &>/dev/null
	[[ -x /sbin/lvm ]] && \
		/sbin/lvm vgscan -P --mknodes --ignorelockingfailure &>/dev/null
	[[ -x /sbin/evms_activate ]] && /sbin/evms_activate -q &>/dev/null

	# Create problematic directories
	mkdir -p /dev/{pts,shm}

	# Same thing as /dev/.devfsd
	touch /dev/.udev

	return 0
}

main() {
		# Setup temporary storage for /dev
		ebegin "Mounting /dev for udev"
		if [[ ${RC_USE_FSTAB} == "yes" ]] ; then
			mntcmd=$(get_mount_fstab /dev)
		else
			unset mntcmd
		fi
		if [[ -n ${mntcmd} ]] ; then
			try mount -n ${mntcmd}
		else
			if egrep -qs tmpfs /proc/filesystems ; then
				mntcmd="tmpfs"
			else
				mntcmd="ramfs"
			fi
			# many video drivers require exec access in /dev #92921
			try mount -n -t ${mntcmd} udev /dev -o exec,nosuid,mode=0755
		fi
		eend $?

		# Selinux lovin; /selinux should be mounted by selinux-patched init
		if [[ -x /sbin/restorecon && -c /selinux/null ]] ; then
			restorecon /dev &> /selinux/null
		fi

		# Actually get udev rolling
		ebegin "Configuring system to use udev"
		if [[ ${RC_DEVICE_TARBALL} == "yes" && \
		      -s /lib/udev-state/devices.tar.bz2 ]] ; then
			einfo "  Populating /dev with device nodes ..."
			try tar -jxpf /lib/udev-state/devices.tar.bz2 -C /dev
		fi

		einfo "  Starting udevd ..."
		/sbin/udevd --daemon

		einfo "  Populating /dev with existing devices ..."
		populate_udev

		# Setup hotplugging (if possible)
		if [[ -e /proc/sys/kernel/hotplug ]] ; then
			if [[ $(udev_version) -ge "48" ]] ; then
				einfo "  Setting /sbin/udevsend as hotplug agent ..."
				echo "/sbin/udevsend" > /proc/sys/kernel/hotplug
			elif [[ -x /sbin/hotplug ]] ; then
				einfo "  Using /sbin/hotplug as hotplug agent ..."
			else
				einfo "  Setting /sbin/udev as hotplug agent ..."
				echo "/sbin/udev" > /proc/sys/kernel/hotplug
			fi
		fi
		eend 0
}

main


# vim:ts=4
