# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev/udev-103.ebuild,v 1.6 2006/12/11 16:05:36 gustavoz Exp $

inherit eutils flag-o-matic multilib

DESCRIPTION="Linux dynamic and persistent device naming support (aka userspace devfs)"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html"
SRC_URI="mirror://kernel/linux/utils/kernel/hotplug/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 arm hppa ia64 m68k ~mips ~ppc ppc64 s390 sh sparc x86"
IUSE="selinux"

# still rely on hotplug (need to fix that), but now we implement coldplug

DEPEND="sys-apps/hotplug-base"
RDEPEND="!sys-apps/coldplug"
RDEPEND="${DEPEND} ${RDEPEND}
	>=sys-apps/baselayout-1.11.14"
# We need the lib/rcscripts/addon support
PROVIDE="virtual/dev-manager"

src_unpack() {
	unpack ${A}

	cd "${S}"

	# patches go here...
	#epatch ${FILESDIR}/${P}-udev_volume_id.patch

	# No need to clutter the logs ...
	sed -ie '/^DEBUG/ c\DEBUG = false' Makefile
	# Do not use optimization flags from the package
	sed -ie 's|$(OPTIMIZATION)||g' Makefile

	# Make sure there is no sudden changes to udev.rules.gentoo
	# (more for my own needs than anything else ...)
	MD5=`md5sum < "${S}/etc/udev/gentoo/udev.rules"`
	MD5=${MD5/  -/}
	if [ "${MD5}" != "295a9b7bdc8bdb239f8860d14af761b0" ]
	then
		echo
		eerror "gentoo/udev.rules has been updated, please validate!"
		die "gentoo/udev.rules has been updated, please validate!"
	fi
}

src_compile() {
	filter-flags -fprefetch-loop-arrays
	local myconf=
	local extras="extras/ata_id \
				  extras/cdrom_id \
				  extras/dasd_id \
				  extras/edd_id \
				  extras/firmware \
				  extras/floppy \
				  extras/path_id \
				  extras/run_directory \
				  extras/scsi_id \
				  extras/usb_id \
				  extras/volume_id \
				  extras/rule_generator"

	use selinux && myconf="${myconf} USE_SELINUX=true"

	# Not everyone has full $CHOST-{ld,ar,etc...} yet
	local mycross=""
	type -p ${CHOST}-ar && mycross=${CHOST}-

	echo "get_libdir = $(get_libdir)"
	# Do not work with emake
	make \
		EXTRAS="${extras}" \
		udevdir="/dev/" \
		CROSS_COMPILE=${mycross} \
		${myconf} || die
}

src_install() {
	# we install everything by "hand" and don't rely on the udev Makefile to do
	# it for us (why? it's easier that way...)
	dobin udevinfo		|| die "Required binary not installed properly"
	dobin udevtest		|| die "Required binary not installed properly"
	dobin udevmonitor	|| die "Required binary not installed properly"
	into /
	dosbin udevd		|| die "Required binary not installed properly"
	dosbin udevstart	|| die "Required binary not installed properly"
	dosbin udevtrigger	|| die "Required binary not installed properly"
	dosbin udevcontrol	|| die "Required binary not installed properly"
	dosbin udevsettle	|| die "Required binary not installed properly"

	# need to keep this until /sbin/rc stops checking for its presence, it's
	# really not needed for us to work properly at all.
	dosbin udev			|| die "Required binary not installed properly"

	# Helpers
	exeinto /lib/udev
	doexe extras/run_directory/udev_run_devd	|| die "Required helper not installed properly"
	doexe extras/run_directory/udev_run_hotplugd	|| die "Required helper not installed properly"
	doexe extras/ata_id/ata_id		|| die "Required helper not installed properly"
	doexe extras/volume_id/vol_id	|| die "Required helper not installed properly"
	doexe extras/scsi_id/scsi_id	|| die "Required helper not installed properly"
	doexe extras/usb_id/usb_id		|| die "Required helper not installed properly"
	doexe extras/path_id/path_id	|| die "Required helper not installed properly"
	doexe extras/cdrom_id/cdrom_id	|| die "Required helper not installed properly"
	doexe extras/dasd_id/dasd_id	|| die "Required helper not installed properly"
	doexe extras/edd_id/edd_id		|| die "Required helper not installed properly"
	doexe extras/rule_generator/write_cd_rules	|| die "Required helper not installed properly"
	doexe extras/rule_generator/write_net_rules	|| die "Required helper not installed properly"
	doexe extras/rule_generator/rule_generator.functions	|| die "Required helper not installed properly"
	keepdir /lib/udev/state

	# vol_id library (needed by mount and HAL)
	dolib extras/volume_id/lib/*.a extras/volume_id/lib/*.so*
	# move the .a files to /usr/lib
	dodir /usr/$(get_libdir)
	mv -f "${D}"/$(get_libdir)/*.a  "${D}"/usr/$(get_libdir)/

	# handle static linking bug #4411
	gen_usr_ldscript libvolume_id.so

	# save pkgconfig info
	insinto /usr/$(get_libdir)/pkgconfig
	doins extras/volume_id/lib/*.pc

	#exeinto /etc/udev/scripts
	exeinto /lib/udev
	#doexe extras/ide-devfs.sh
	#doexe extras/scsi-devfs.sh
	#doexe extras/raid-devfs.sh
	doexe extras/floppy/create_floppy_devices	|| die "Required binary not installed properly"
	doexe extras/firmware/firmware.sh			|| die "Required binary not installed properly"
	doexe ${FILESDIR}/seq_node.sh				|| die "Required binary not installed properly"

	# Our udev config file
	insinto /etc/udev
	newins ${FILESDIR}/udev.conf.post_081 udev.conf

	# Our rules files
	insinto /etc/udev/rules.d/
	newins etc/udev/gentoo/udev.rules 50-udev.rules
	newins ${FILESDIR}/udev.rules-098 50-udev.rules
	newins ${FILESDIR}/05-udev-early.rules-079 05-udev-early.rules
	# Use upstream's persistent rules for devices
	doins etc/udev/rules.d/60-*.rules
	doins extras/rule_generator/75-*.rules || die "rules not installed properly"

	# scsi_id configuration
	insinto /etc
	doins extras/scsi_id/scsi_id.config

	# set up the /etc/dev.d directory tree
	dodir /etc/dev.d/default
	dodir /etc/dev.d/net
	exeinto /etc/dev.d/net
	doexe extras/run_directory/dev.d/net/hotplug.dev

	# all of the man pages
	doman *.7
	doman *.8
	doman extras/ata_id/ata_id.8
	doman extras/edd_id/edd_id.8
	doman extras/scsi_id/scsi_id.8
	doman extras/volume_id/vol_id.8
	doman extras/dasd_id/dasd_id.8
	doman extras/cdrom_id/cdrom_id.8
	# create a extra symlink for udevcontrol
	ln -s "${D}"/usr/share/man/man8/udevd.8.gz \
		"${D}"/usr/share/man/man8/udevcontrol.8.gz

	# our udev hooks into the rc system
	insinto /lib/rcscripts/addons
	newins "${FILESDIR}"/udev-start-099.sh udev-start.sh
	doins "${FILESDIR}"/udev-stop.sh

	# needed to compile latest Hal
	insinto /usr/include
	doins extras/volume_id/lib/libvolume_id.h

	dodoc ChangeLog FAQ README TODO RELEASE-NOTES
	dodoc docs/{overview,udev_vs_devfs}
	dodoc docs/writing_udev_rules/*

	newdoc extras/volume_id/README README_volume_id

}

pkg_preinst() {
	if [[ -d ${ROOT}/lib/udev-state ]] ; then
		mv -f "${ROOT}"/lib/udev-state/* "${D}"/lib/udev/state/
		rm -r "${ROOT}"/lib/udev-state
	fi

	if [ -f "${ROOT}/etc/udev/udev.config" -a \
	     ! -f "${ROOT}/etc/udev/udev.rules" ]
	then
		mv -f ${ROOT}/etc/udev/udev.config ${ROOT}/etc/udev/udev.rules
	fi

	# delete the old udev.hotplug symlink if it is present
	if [ -h "${ROOT}/etc/hotplug.d/default/udev.hotplug" ]
	then
		rm -f ${ROOT}/etc/hotplug.d/default/udev.hotplug
	fi

	# delete the old wait_for_sysfs.hotplug symlink if it is present
	if [ -h "${ROOT}/etc/hotplug.d/default/05-wait_for_sysfs.hotplug" ]
	then
		rm -f ${ROOT}/etc/hotplug.d/default/05-wait_for_sysfs.hotplug
	fi

	# delete the old wait_for_sysfs.hotplug symlink if it is present
	if [ -h "${ROOT}/etc/hotplug.d/default/10-udev.hotplug" ]
	then
		rm -f ${ROOT}/etc/hotplug.d/default/10-udev.hotplug
	fi

	# is there a stale coldplug initscript? (CONFIG_PROTECT leaves it behind)
	coldplug_stale=""
	if [ -f "${ROOT}/etc/init.d/coldplug" ]
	then
		coldplug_stale="1"
	fi

	# Create some nodes that we know we need.
	# set the time/date so we can see in /dev which ones we copied over
	# in the udev-start.sh script
	mkdir -p ${ROOT}/lib/udev/devices

	if [ ! -e ${ROOT}/lib/udev/devices/null ] ; then
	    mknod ${ROOT}/lib/udev/devices/null c 1 3
	fi
	chmod 666 ${ROOT}/lib/udev/devices/null
	touch -t 200010220101 ${ROOT}/lib/udev/devices/null

	if [ ! -e ${ROOT}/lib/udev/devices/zero ] ; then
	    mknod ${ROOT}/lib/udev/devices/zero c 1 5
	fi
	chmod 666 ${ROOT}/lib/udev/devices/zero
	touch -t 200010220101 ${ROOT}/lib/udev/devices/zero

	if [ ! -e ${ROOT}/lib/udev/devices/console ] ; then
	    mknod ${ROOT}/lib/udev/devices/console c 5 1
	fi
	chmod 600 ${ROOT}/lib/udev/devices/console
	chown root:tty ${ROOT}/lib/udev/devices/console
	touch -t 200010220101 ${ROOT}/lib/udev/devices/console

	if [ ! -e ${ROOT}/lib/udev/devices/urandom ] ; then
	    mknod ${ROOT}/lib/udev/devices/urandom c 1 9
	fi
	chmod 666 ${ROOT}/lib/udev/devices/urandom
	touch -t 200010220101 ${ROOT}/lib/udev/devices/urandom
}

pkg_postinst() {
	if [ "${ROOT}" = "/" -a -n "`pidof udevd`" ]
	then
		killall -15 udevd &>/dev/null
		sleep 1
		killall -9 udevd &>/dev/null
	fi
	/sbin/udevd --daemon

	# people want reminders, I'll give them reminders.  Odds are they will
	# just ignore them anyway...
	if has_version '<sys-fs/udev-046' ; then
		ewarn "Note: If you rely on the output of udevinfo for anything, please"
		ewarn "      either run 'udevstart' now, or reboot, in order to get a"
		ewarn "      up-to-date udev database."
		ewarn
	fi
	if has_version '<sys-fs/udev-050' ; then
		ewarn "Note: If you had written some custom permissions rules, please"
		ewarn "      realize that the permission rules are now part of the main"
		ewarn "      udev rules files and are not stand-alone anymore.  This means"
		ewarn "      you need to rewrite them."
		ewarn
	fi
	if has_version '<sys-fs/udev-059' ; then
		ewarn "Note: If you are upgrading from a version of udev prior to 059"
		ewarn "      and you have written custom rules, and rely on the etc/dev.d/"
		ewarn "      functionality, or the etc/hotplug.d functionality, or just"
		ewarn "      want to write some very cool and power udev rules, please "
		ewarn "      read the RELEASE-NOTES file for details on what has changed"
		ewarn "      with this feature, and how to change your rules to work properly."
		ewarn
	elif has_version '<sys-fs/udev-057' ; then
		ewarn "Note: If you have written custom rules, and rely on the etc/dev.d/"
		ewarn "      functionality, please read the RELEASE-NOTES file for details"
		ewarn "      on what has changed with this feature, and how to change your"
		ewarn "      rules to work properly."
		ewarn
	fi
	if has_version '<sys-fs/udev-063' ; then
		ewarn "Note: If you use the devfs-style names for your block devices"
		ewarn "      or use devfs-style names in /etc/inittab or /etc/securetty or"
		ewarn "      your GRUB or LILO kernel boot command line, you need to"
		ewarn "      change them back to LSB compliant names, as the devfs names are"
		ewarn "      now gone.  If you wish to use some persistent names for your"
		ewarn "      block devices, look at the symlinks in /dev/disk/ for the names"
		ewarn "      you can use."
		ewarn
	fi

	if [[ ${coldplug_stale} == "1" ]] ; then
		ewarn "A stale coldplug init script found. You should run:"
		ewarn
		ewarn "      rc-update del coldplug"
		ewarn "      rm -f /etc/init.d/coldplug"
		ewarn
		ewarn "udev now provides its own coldplug functionality."
	fi

	einfo
	einfo "For more information on udev on Gentoo, writing udev rules, and"
	einfo "         fixing known issues visit:"
	einfo "         http://www.gentoo.org/doc/en/udev-guide.xml"
}
