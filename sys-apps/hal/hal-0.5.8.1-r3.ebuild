# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hal/hal-0.5.7.1-r2.ebuild,v 1.1 2006/11/15 21:02:48 cardoe Exp $

inherit eutils linux-info
inherit eutils linux-info flag-o-matic

DESCRIPTION="Hardware Abstraction Layer"
HOMEPAGE="http://www.freedesktop.org/Software/hal"
SRC_URI="http://freedesktop.org/~david/dist/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.0 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="acpi crypt debug doc dmi pcmcia selinux"

RDEPEND=">=dev-libs/glib-2.6
	|| ( >=dev-libs/dbus-glib-0.71
		( =sys-apps/dbus-0.60 ) )
	>=sys-fs/udev-100
	>=sys-apps/util-linux-2.12r
	|| ( >=sys-kernel/linux-headers-2.6 >=sys-kernel/mips-headers-2.6 )
	dev-libs/expat
	sys-libs/libcap
	sys-apps/pciutils
	dev-libs/libusb
	sys-apps/hotplug
	virtual/eject
	dmi? ( >=sys-apps/dmidecode-2.7 )
	crypt? ( >=sys-fs/cryptsetup-luks-1.0.1 )
	selinux? ( sys-libs/libselinux )"

DEPEND="${RDEPEND}
	!sys-fs/ntfs-policy
	dev-util/pkgconfig
	>=dev-util/intltool-0.29
	doc? ( app-doc/doxygen app-text/docbook-sgml-utils )"

## HAL Daemon drops privledges so we need group access to read disks
HALDAEMON_GROUPS="haldaemon,plugdev,disk,cdrom,cdrw,floppy,usb"

# We need to add permissions to /var/lib/run/hald
addwrite /var/lib/run/
addpredict /var/lib/run/
addwrite /var/lib/run/hald
addpredict /var/lib/run/hald



function notify_uevent() {
	eerror
	eerror "You must enable Kernel Userspace Events in your kernel."
	eerror "This can be set under 'General Setup'.  It is marked as"
	eerror "CONFIG_KOBJECT_UEVENT in the config file."
	eerror
	ebeep 5
}

function notify_uevent_2_6_16() {
	eerror
	eerror "You must enable Kernel Userspace Events in your kernel."
	eerror "For this you need to enable 'Hotplug' under 'General Setup' and"
	eerror "basic networking.  They are marked CONFIG_HOTPLUG and CONFIG_NET"
	eerror "in the config file."
	eerror
	ebeep 5
}

function notify_procfs() {
	eerror
	eerror "You must enable the proc filesystem in your kernel."
	eerror "For this you need to enable '/proc file system support' under"
	eerror "'Pseudo filesystems' in 'File systems'.  It is marked"
	eerror "CONFIG_PROC_FS in the config file."
	eerror
	ebeep 5
}

pkg_setup() {
	get_version || eerror "Unable to calculate Linux Kernel version"

	kernel_is ge 2 6 15 || eerror "HAL requires a kernel version 2.6.15 or newer"

	if kernel_is lt 2 6 16 ; then
		linux_chkconfig_present KOBJECT_UEVENT || notify_uevent
	else
		(linux_chkconfig_present HOTPLUG && linux_chkconfig_present NET) \
			|| notify_uevent_2_6_16
	fi

	if use acpi ; then
		linux_chkconfig_present PROC_FS || notify_procfs
	fi

	if [ -d ${ROOT}/etc/hal/device.d ]; then
		eerror "HAL 0.5.x will not run with the HAL 0.4.x series of"
		eerror "/etc/hal/device.d/ so please remove this directory"
		eerror "with rm -rf /etc/hal/device.d/ and then re-emerge."
		eerror "This is due to configuration protection of /etc/"
		die "remove /etc/hal/device.d/"
	fi

}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# allow plugdev group people to mount
	epatch ${FILESDIR}/${PN}-0.5.8.1-plugdev-allow-send.patch

	# use ntfs-fuse by default
	epatch ${FILESDIR}/${PN}-0.5.8.1-sabayonlinux-ntfs-fuse.default.patch

	#### From FC7 src.rpm

	# do not crash on cdrom drives - aka r/o storage
	epatch ${FILESDIR}/${PN}-0.5.8.1-dont-crash-on-cdrom-drives.patch

	# fix partutil
	epatch ${FILESDIR}/${PN}-0.5.8.1-partutil-fix.patch

	# remove link only
	epatch ${FILESDIR}/${PN}-0.5.8.1-remove-link-not-remove.patch

	# wrong stat
	epatch ${FILESDIR}/${PN}-0.5.8.1-stat-devicefile-not-mountpoint.patch

	# align !
	epatch ${FILESDIR}/${PN}-alignment.patch

	# Add TabletPC magic
	epatch ${FILESDIR}/${PN}-0.5.8.1-add-tabletPC-support.patch


	### From ARCH Linux
	
	# check for error in case of floppy or cdrom drives
	epatch ${FILESDIR}/${PN}-0.5.8.1-check-for-error.patch


}

src_compile() {

if [ -r "${ROOT}/usr/share/misc/pci.ids.gz" ] ; then
		hwdata="${ROOT}/usr/share/misc/pci.ids.gz"
	elif [ -r "${ROOT}/usr/share/misc/pci.ids" ] ; then
		hwdata="${ROOT}/usr/share/misc/pci.ids"
	else
		die "pci.ids file not found. please file a bug @ bugs.sabayonlinux.org"
	fi

	econf \
                --with-hwdata=${hwdata} \
                --with-hwdata=/usr/share/misc/pci.ids.gz \
		--with-doc-dir=/usr/share/doc/${PF} \
		--with-os-type=gentoo \
		--with-pid-file=/var/run/hald.pid \
		--with-hwdata=${hwdata} \
		--enable-hotplug-map \
		--disable-policy-kit \
		$(use_enable debug verbose-mode) \
		$(use_enable pcmcia pcmcia-support) \
		$(use_enable acpi acpi-proc) \
		$(use_enable doc docbook-docs) \
		$(use_enable doc doxygen-docs) \
		$(use_enable selinux) \
		|| die "configure failed"

	
        append-ldflags -lz
        emake LDFLAGS="${LDFLAGS}" || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README

	# remove dep on gnome-python
	mv "${D}"/usr/bin/hal-device-manager "${D}"/usr/share/hal/device-manager/

	# initscript
	newinitd "${FILESDIR}"/0.5-hald.rc hald

	# We now create and keep /media here as both gnome-mount and pmount
	# use these directories, to avoid collision.
	dodir /media
	keepdir /media

}

pkg_postinst() {
	# Despite what people keep changing this location. Either one works.. it doesn't matter
	# http://dev.gentoo.org/~plasmaroo/devmanual/ebuild-writing/functions/

	# Create groups for hotplugging and HAL
	enewgroup haldaemon || die "Problem adding haldaemon group"
	enewgroup plugdev || die "Problem adding plugdev group"

	# HAL drops priviledges by default now ...
	# ... so we must make sure it can read disk/cdrom info (ie. be in ${HALDAEMON_GROUPS} groups)
	enewuser haldaemon -1 "-1" /dev/null ${HALDAEMON_GROUPS} || die "Problem adding haldaemon user"

	# Make sure that the haldaemon user is in the ${HALDAEMON_GROUPS}
	# If users have a problem with this, let them file a bug
	usermod -G ${HALDAEMON_GROUPS} haldaemon

	elog "The HAL daemon needs to be running for certain applications to"
	elog "work. Suggested is to add the init script to your start-up"
	elog "scripts, this should be done like this :"
	elog "\`rc-update add hald default\`"
	echo
	elog "Looking for automounting support? Add yourself to the plugdev group"
}
