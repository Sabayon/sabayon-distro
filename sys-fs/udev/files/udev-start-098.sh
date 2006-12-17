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
	# populate /dev with devices already found by the kernel
	if [ $(get_KV) -gt "$(KV_to_int '2.6.14')" ] ; then
		ebegin "Populating /dev with existing devices through uevents"
		local opts=
		[[ ${RC_COLDPLUG} != "yes" && $(udev_version) -ge "96" ]] && \
			opts="--no-scan-bus"
		/sbin/udevtrigger ${opts}
		eend $?
	else
		ebegin "Populating /dev with existing devices with udevstart"
		/sbin/udevstart
		eend $?
	fi

	# loop until everything is finished
	# there's gotta be a better way...
	ebegin "Letting udev process events"
	/sbin/udevsettle --timeout=60
	eend $?

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
		# This is bash only, but saves on using grep
		if [[ $(</proc/filesystems)$'\n' =~ '[[:space:]]tmpfs'$'\n' ]] ; then
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
	      -s /lib/udev/state/devices.tar.bz2 ]] ; then
		ebegin "Populating /dev with saved device nodes"
		try tar -jxpf /lib/udev/state/devices.tar.bz2 -C /dev
		eend $?
	fi

	seed_dev

	# Setup hotplugging (if possible)
	if [[ -e /proc/sys/kernel/hotplug ]] ; then
		ebegin "Setting up proper hotplug agent"
		eindent
		if [[ $(get_KV) -gt $(KV_to_int '2.6.14') ]] ; then
			einfo "Using netlink for hotplug events..."
			echo "" > /proc/sys/kernel/hotplug
		else
			einfo "Setting /sbin/udevsend as hotplug agent ..."
			echo "/sbin/udevsend" > /proc/sys/kernel/hotplug
		fi
		eoutdent
		eend 0
	fi

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
