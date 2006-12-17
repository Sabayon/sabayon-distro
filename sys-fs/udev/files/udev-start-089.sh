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

# This works for 2.6.15 kernels or greater
trigger_events() {
	list=""
	# if you want real coldplug (with all modules being loaded for all
	# devices in the system), uncomment out the next line.
	#list="$list $(echo /sys/bus/*/devices/*/uevent)"
	list="$list $(echo /sys/class/*/*/uevent)"
	list="$list $(echo /sys/block/*/uevent /sys/block/*/*/uevent)"
	for i in $list; do
		case "$i" in
			*/device/uevent)
				# skip followed device symlinks
				continue
				;;
			*/class/mem/*|*/class/tty/*)
				first="$first $i"
				;;
			*/block/md*)
				last="$last $i"
				;;
			*/*)
				default="$default $i"
				;;
		esac
	done

	# trigger the sorted events
	for i in $first $default $last; do
		echo "add" > "$i"
	done
}

populate_udev() {
	# populate /dev with devices already found by the kernel
	if [ "$(get_KV)" -gt "$(KV_to_int '2.6.14')" ] ; then
		ebegin "Populating /dev with existing devices through uevents"
		udevtrigger
		eend 0
	else
		ebegin "Populating /dev with existing devices with udevstart"
		/sbin/udevstart
		eend 0
	fi

	# loop until everything is finished
	# there's gotta be a better way...
	ebegin "Letting udev process events"
	loop=0
	while test -d /dev/.udev/queue; do
		sleep 0.1;
		test "$loop" -gt 300 && break
		loop=$(($loop + 1))
	done
	#einfo "loop = $loop"
	eend 0

	return 0
}

seed_dev() {
	# Seed /dev with some things that we know we need
	ebegin "Seeding /dev with needed nodes"

	# copy over any persistant things
	if [[ -d /lib/udev/devices ]] ; then
		cp --preserve=all --recursive --update /lib/udev/devices/* /dev
	fi

	# Not provided by sysfs but needed
	ln -snf /proc/self/fd /dev/fd
	ln -snf fd/0 /dev/stdin
	ln -snf fd/1 /dev/stdout
	ln -snf fd/2 /dev/stderr
	[[ -e /proc/kcore ]] && ln -snf /proc/kcore /dev/core

	# Create problematic directories
	mkdir -p /dev/{pts,shm}
	eend 0
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

	# Create a file so that our rc system knows it's still in sysinit.
	# Existance means init scripts will not directly run.
	# rc will remove the file when done with sysinit.
	touch /dev/.rcsysinit

	# Selinux lovin; /selinux should be mounted by selinux-patched init
	if [[ -x /sbin/restorecon && -c /selinux/null ]] ; then
		restorecon /dev &> /selinux/null
	fi

	# Actually get udev rolling
	if [[ ${RC_DEVICE_TARBALL} == "yes" && \
	      -s /lib/udev-state/devices.tar.bz2 ]] ; then
		ebegin "Populating /dev with saved device nodes"
		try tar -jxpf /lib/udev-state/devices.tar.bz2 -C /dev
		eend $?
	fi

	seed_dev

	# Setup hotplugging (if possible)
	ebegin "Setting up proper hotplug agent"
	if [[ -e /proc/sys/kernel/hotplug ]] ; then
		if [ "$(get_KV)" -gt "$(KV_to_int '2.6.14')" ] ; then
			einfo "  Using netlink for hotplug events..."
			echo "" > /proc/sys/kernel/hotplug
		elif [[ $(udev_version) -ge "48" ]] ; then
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

	ebegin "Starting udevd"
	/sbin/udevd --daemon
	eend $?

	populate_udev

	# Create nodes that udev can't
	ebegin "Finalizing udev configuration"
	[[ -x /sbin/dmsetup ]] && /sbin/dmsetup mknodes &>/dev/null
	[[ -x /sbin/lvm ]] && \
		/sbin/lvm vgscan -P --mknodes --ignorelockingfailure &>/dev/null
	# Running evms_activate on a LiveCD causes lots of headaches
	[[ -z ${CDBOOT} ]] && [[ -x /sbin/evms_activate ]] && \
		/sbin/evms_activate -q &>/dev/null
	eend 0
}

main


# vim:ts=4
