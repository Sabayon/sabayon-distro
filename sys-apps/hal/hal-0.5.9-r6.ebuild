# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hal/hal-0.5.7.1-r2.ebuild,v 1.1 2006/11/15 21:02:48 cardoe Exp $

inherit eutils linux-info
inherit eutils linux-info flag-o-matic

GIT_DATE="20070402"
DESCRIPTION="Hardware Abstraction Layer"
HOMEPAGE="http://www.freedesktop.org/Software/hal"
SRC_URI="
	http://www.sabayonlinux.org/distfiles/sys-apps/${P}.tar.gz
	http://www.sabayonlinux.org/distfiles/sys-apps/${PN}-info-${GIT_DATE}.tar.gz
	"

LICENSE="|| ( GPL-2 AFL-2.0 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="acpi crypt debug doc pcmcia selinux ell disk-partition"

RDEPEND=">=dev-libs/glib-2.6
	|| ( >=dev-libs/dbus-glib-0.71
		( <sys-apps/dbus-0.70 ) )
	>=sys-fs/udev-100
	>=sys-apps/util-linux-2.12r
	|| ( >=sys-kernel/linux-headers-2.6 >=sys-kernel/mips-headers-2.6 )
	dev-libs/expat
	sys-libs/libcap
	sys-apps/pciutils
	dev-libs/libusb
	sys-apps/hotplug
	virtual/eject
	>=sys-fs/ntfs3g-1.0
	x86? ( >=sys-apps/dmidecode-2.7 )
	amd64? ( >=sys-apps/dmidecode-2.7 )
	dell? ( >=sys-libs/libsmbios-0.13.4 )
	disk-partition? ( >=sys-apps/parted-1.7.1 )
	crypt? ( >=sys-fs/cryptsetup-luks-1.0.1 )
	selinux? ( sys-libs/libselinux sec-policy/selinux-hal )
	"

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
	epatch ${FILESDIR}/${P}-plugdev-allow-send.patch

	# use ntfs-3g, then ntfs-fuse by default
	epatch ${FILESDIR}/${P}-sabayonlinux-ntfs-3g.default.patch

	# Write proper suspend priorities
	epatch ${FILESDIR}/${P}-suspend-priorities.patch

	# Patches accepted upstream
        epatch ${FILESDIR}/${PV}/01_luks_mount_fix.patch
        epatch ${FILESDIR}/${PV}/02_acpi_repeated_property_change.patch
        epatch ${FILESDIR}/${PV}/03_crasher_fix_fail_to_return_value.patch
        epatch ${FILESDIR}/${PV}/04_cache_regen_return_fix.patch
        epatch ${FILESDIR}/${PV}/05_freebsd_partutil_make_fix.patch
        epatch ${FILESDIR}/${PV}/06_freebsd_backend_fix.patch
        epatch ${FILESDIR}/${PV}/07_malloc_h_for_stdlib_h.patch
        epatch ${FILESDIR}/${PV}/08_contains_not_fdi_directive.patch
        epatch ${FILESDIR}/${PV}/09_hald_addon_keyboard_start_one.patch
        epatch ${FILESDIR}/${PV}/10_freebsd_storage_reprobe_fix.patch
        epatch ${FILESDIR}/${PV}/11_hal_fix_segfault_probe_volume.patch
        epatch ${FILESDIR}/${PV}/12_hal_fix-vol_label_probe_volume.patch
        epatch ${FILESDIR}/${PV}/13_detect_newer_macbooks.patch
        epatch ${FILESDIR}/${PV}/14_ntfs_allows_utf8.patch
        epatch ${FILESDIR}/${PV}/15_spec_fdi_matching.patch
        epatch ${FILESDIR}/${PV}/16_dev_root_is_mounted.patch
        epatch ${FILESDIR}/${PV}/18_hal_fix_info.category_for_laptop_panel_v2.patch
        epatch ${FILESDIR}/${PV}/19_hald_runner_catch_dbus_disconnect.patch


}

src_compile() {

if [ -r "${ROOT}/usr/share/misc/pci.ids.gz" ] ; then
		hwdata="${ROOT}/usr/share/misc/pci.ids.gz"
	elif [ -r "${ROOT}/usr/share/misc/pci.ids" ] ; then
		hwdata="${ROOT}/usr/share/misc/pci.ids"
	else
		die "pci.ids file not found. please file a bug @ bugs.sabayonlinux.org"
	fi

        if ! use acpi ; then
                acpi="--disable-acpi-proc --disable-acpi-acpid"
        fi

	econf \
                --with-usb-ids=/usr/share/misc/ \
                --with-pci-ids=/usr/share/misc/ \
		--with-doc-dir=/usr/share/doc/${PF} \
		--with-os-type=gentoo \
		--with-pid-file=/var/run/hald.pid \
		--with-socket-dir=/var/run/hald \
		--with-hwdata=${hwdata} \
		--enable-hotplug-map \
		--disable-policy-kit \
		--disable-console-kit \
		$(use_enable debug verbose-mode) \
		$(use_enable pcmcia pcmcia-support) \
		$(use_enable acpi acpi-proc) \
		$(use_with dell dell-backlight) \
		$(use_enable disk-partition parted) \
		$(use_enable doc docbook-docs) \
		$(use_enable doc doxygen-docs) \
		$(use_enable selinux) \
		${acpi} || die "configure failed"

	
        append-ldflags -lz
        emake LDFLAGS="${LDFLAGS}" || die "make failed"

	cd ${WORKDIR}/hal-info-${GIT_DATE}
	econf || die "hal-info configure failed"
	emake || die "hal-info make failed"

}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README

	# remove dep on gnome-python
	mv "${D}"/usr/bin/hal-device-manager "${D}"/usr/share/hal/device-manager/

        # hal umount for unclean unmounts
        exeinto /lib/udev/
        newexe "${FILESDIR}"/hal-unmount.dev hal_unmount

        # initscript
        newinitd "${FILESDIR}"/0.5.9-hald.rc hald
        cp "${FILESDIR}"/0.5.9-hald.conf "${WORKDIR}"/
        if use debug; then
                sed -e 's:HALD_VERBOSE="no":HALD_VERBOSE="yes":' \
                -i "${WORKDIR}"/0.5.9-hald.conf
        fi
        newconfd "${WORKDIR}"/0.5.9-hald.conf hald

	# We now create and keep /media here as both gnome-mount and pmount
	# use these directories, to avoid collision.
	dodir /media
	keepdir /media

	# Fix hald running issue, create missing dir
	dodir /etc/hal/fdi
	dodir /etc/hal/fdi/policy
	dodir /etc/hal/fdi/preprobe
	dodir /etc/hal/fdi/information
	dodir /var/lib/cache/hald
	dodir /var/run/hald
	keepdir /var/lib/cache/hald
	keepdir /etc/hal/fdi
	keepdir /etc/hal/fdi/policy
	keepdir /etc/hal/fdi/preprobe
	keepdir /etc/hal/fdi/information
	keepdir /var/run/hald

	cd ${WORKDIR}/hal-info-${GIT_DATE}
	make DESTDIR="${D}" install || die


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

	# Fix permissions
	chown -R haldaemon:haldaemon "${D}"/var/lib/cache/hald

	elog "The HAL daemon needs to be running for certain applications to"
	elog "work. Suggested is to add the init script to your start-up"
	elog "scripts, this should be done like this :"
	elog "\`rc-update add hald default\`"
	echo
	elog "Looking for automounting support? Add yourself to the plugdev group"
}
