# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hal/hal-0.5.10.ebuild,v 1.9 2008/02/08 20:11:00 wolf31o2 Exp $

inherit eutils linux-info autotools flag-o-matic

PATCH_VER="0"

DESCRIPTION="Hardware Abstraction Layer"
HOMEPAGE="http://www.freedesktop.org/Software/hal"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.gz
		http://dev.gentoo.org/~compnerd/files/${PN}/${P}-gentoo-patches-${PATCH_VER}.tar.bz2"

LICENSE="|| ( GPL-2 AFL-2.0 )"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~x86"

KERNEL_IUSE="kernel_linux kernel_FreeBSD"
IUSE="acpi apm crypt debug dell disk-partition doc laptop selinux ${KERNEL_IUSE}"

RDEPEND=">=dev-libs/glib-2.6
		 >=dev-libs/dbus-glib-0.61
		 >=dev-libs/expat-1.95.8
		 >=sys-apps/pciutils-2.2.7-r1
		 >=dev-libs/libusb-0.1.10a
		 >=dev-util/gperf-3.0.3
		   sys-apps/usbutils
		   virtual/eject
		 amd64? ( >=sys-apps/dmidecode-2.7 )
		 dell? ( >=sys-libs/libsmbios-0.13.4 )
		 disk-partition? (
							||  (
									~sys-apps/parted-1.7.1
									~sys-apps/parted-1.8.6
									~sys-apps/parted-1.8.7
								)
						 )
		 ia64? ( >=sys-apps/dmidecode-2.7 )
		 kernel_linux?	(
							>=sys-fs/udev-111
							>=sys-apps/util-linux-2.13
							>=sys-kernel/linux-headers-2.6.19
							crypt?	(
										||	(
												>=sys-fs/cryptsetup-1.0.5
												>=sys-fs/cryptsetup-luks-1.0.1
											)
									)
						)
		 kernel_FreeBSD? ( dev-libs/libvolume_id )
		 x86? ( >=sys-apps/dmidecode-2.7 )
		 selinux? ( sys-libs/libselinux sec-policy/selinux-hal )"
DEPEND="${RDEPEND}
		dev-util/pkgconfig
		>=dev-util/intltool-0.35
		doc?	(
					app-doc/doxygen
					app-text/docbook-sgml-utils
					app-text/xmlto
					dev-libs/libxml2
				)"
PDEPEND=">=app-misc/hal-info-20071011
		 laptop? ( >=sys-power/pm-utils-0.99.3 )"

## HAL Daemon drops privledges so we need group access to read disks
HALDAEMON_GROUPS_LINUX="haldaemon,plugdev,disk,cdrom,cdrw,floppy,usb"
HALDAEMON_GROUPS_FREEBSD="haldaemon,plugdev,operator"

function check_hotplug_net() {
	local CONFIG_CHECK="~HOTPLUG ~NET"
	local WARNING_HOTPLUG="CONFIG_HOTPLUG:\tis not set (required for HAL)"
	local WARNING_NET="CONFIG_NET:\tis not set (required for HAL)"
	check_extra_config
	echo
}

function check_inotify() {
	local CONFIG_CHECK="~INOTIFY_USER"
	local WARNING_INOTIFY_USER="CONFIG_INOTIFY_USER:\tis not set (required for HAL)"
	check_extra_config
	echo
}

function check_acpi_proc() {
	local CONFIG_CHECK="~ACPI_PROCFS ~ACPI_PROC_EVENT"
	local WARNING_ACPI_PROCFS="CONFIG_ACPI_PROCFS:\tis not set (required for HAL)"
	local WARNING_ACPI_PROC_EVENT="CONFIG_ACPI_PROC_EVENT:\tis not set (required for HAL)"
	check_extra_config
	echo
}

pkg_setup() {
	if use kernel_linux ; then
		if [ -e ${ROOT}/usr/src/linux/.config ] ; then
			kernel_is ge 2 6 19 || \
				ewarn "HAL requires a kernel version 2.6.19 or newer"
			if kernel_is lt 2 6 23 && use acpi ; then
				check_acpi_proc
			fi
		fi

		check_hotplug_net
		check_inotify
	fi

	# http://devmanual.gentoo.org/ebuild-writing/functions/
	# http://bugs.gentoo.org/show_bug.cgi?id=191605

	# Create groups for hotplugging and HAL
	enewgroup haldaemon || die "Problem adding haldaemon group"
	enewgroup plugdev || die "Problem adding plugdev group"

	# HAL drops priviledges by default now ...
	# ... so we must make sure it can read disk/cdrom info (ie. be in ${HALDAEMON_GROUPS} groups)
	if use kernel_linux; then
		enewuser haldaemon -1 "-1" /dev/null ${HALDAEMON_GROUPS_LINUX} \
			|| die "Problem adding haldaemon user"
	elif use kernel_FreeBSD; then
		enewuser haldaemon -1 "-1" /dev/null ${HALDAEMON_GROUPS_FREEBSD} \
			|| die "Problem addding haldaemon user"
	fi

	# Make sure that the haldaemon user is in the ${HALDAEMON_GROUPS}
	# If users have a problem with this, let them file a bug
	if [[ ${ROOT} == / ]] ; then
		if use kernel_linux; then
			usermod -G ${HALDAEMON_GROUPS_LINUX} haldaemon
		elif use kernel_FreeBSD; then
			pw usermod haldaemon -G ${HALDAEMON_GROUPS_FREEBSD}
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	EPATCH_MULTI_MSG="Applying Gentoo Patchset ..." \
	EPATCH_SUFFIX="patch" \
	EPATCH_SOURCE="${WORKDIR}/hal-0.5.10-patches/" \
	EPATCH_FORCE="yes" \
	epatch

	# Hide recovery partitions
	epatch "${FILESDIR}/hal-0.5.9-hide-recovery-partitions.patch"

	# Enable plugdev support
	epatch "${FILESDIR}/96_plugdev_allow_send.patch"

	# NTFS-3G support
	epatch "${FILESDIR}"/${P}-sabayonlinux-ntfs-3g.default.patch


	eautoreconf
}

src_compile() {
	local acpi="$(use_enable acpi)"
	local backend=
	local hardware=

	append-flags -rdynamic

	if use kernel_linux ; then
		backend="linux"
	elif use kernel_FreeBSD ; then
		backend="freebsd"
	else
		eerror "Invalid backend"
	fi

	if use kernel_linux ; then
		if use acpi ; then
			# Using IBM ACPI and Toshiba ACPI results in double notification as this
			# was merged into the Linux Kernel 2.6.22
			if kernel_is lt 2 6 22 ; then
				acpi="$acpi --enable-acpi-ibm --enable-acpi-toshiba"
			else
				acpi="$acpi --disable-acpi-ibm --disable-acpi-toshiba"
			fi

			acpi="$acpi --enable-acpi-proc --enable-acpi-acpid"
		else
			acpi="$acpi --disable-acpi-ibm --disable-acpi-toshiba"
			acpi="$acpi --disable-acpi-proc --disable-acpi-acpid"
		fi

		hardware="--with-cpufreq --with-usb-csr --with-keymaps"
		use arm && hardware="$hardware --enable-omap"

		if use dell ; then
			hardware="$hardware --with-dell-backlight"
		else
			hardware="$hardware --without-dell-backlight"
		fi
	else
		hardware="--without-cpufreq --without-usb-csr --without-keymaps"
		hardware="$hardware --disable-omap"
		hardware="$hardware --without-dell-backlight"
		hardware="$hardware --enable-acpi-ibm --enable-acpi-toshiba"
	fi

	econf --with-backend=${backend} \
		  --with-os-type=gentoo \
		  --with-pid-file=/var/run/hald.pid \
		  --with-hwdata=/usr/share/misc \
		  --with-socket-dir=/var/run/hald \
		  --enable-umount-helper \
		  --enable-man-pages \
		  --disable-policy-kit \
		  --disable-console-kit \
		  --disable-acl-management \
		  --enable-pci \
		  --enable-sonypic \
		  $(use_enable apm) \
		  $(use_enable arm pmu) \
		  $(use_enable arm omap) \
		  $(use_enable debug verbose-mode) \
		  $(use_enable disk-partition parted) \
		  $(use_enable doc docbook-docs) \
		  $(use_enable doc doxygen-docs) \
		  --docdir=/usr/share/doc/${PF} \
		  --localstatedir=/var \
		  ${acpi} ${hardware} \
	|| die "configure failed"

	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README

	# hal umount for unclean unmounts
	exeinto /lib/udev/
	newexe "${FILESDIR}"/hal-unmount.dev hal_unmount

	# initscript
	newinitd "${FILESDIR}"/0.5.10-hald.rc hald

	# configuration
	cp "${FILESDIR}"/0.5.10-hald.conf "${WORKDIR}"/

	if use debug; then
		sed -e 's:HALD_VERBOSE="no":HALD_VERBOSE="yes":' \
			-i "${WORKDIR}"/0.5.10-hald.conf
	fi
	newconfd "${WORKDIR}"/0.5.10-hald.conf hald

	# We now create and keep /media here as both gnome-mount and pmount
	# use these directories, to avoid collision.
	keepdir /media

	# We also need to create and keep /etc/fdi/{information,policy,preprobe}
	# or else hal bombs.
	keepdir /etc/hal/fdi/{information,policy,preprobe}

	# HAL stores it's fdi cache in /var/lib/cache/hald
	keepdir /var/lib/cache/hald

	# HAL keeps its unix socket here
	keepdir /var/run/hald
	keepdir /var/lib/hal
}

pkg_postinst() {
	# Despite what people keep changing this location. Either one works.. it doesn't matter
	# http://dev.gentoo.org/~plasmaroo/devmanual/ebuild-writing/functions/

	elog "The HAL daemon needs to be running for certain applications to"
	elog "work. Suggested is to add the init script to your start-up"
	elog "scripts, this should be done like this :"
	elog "\`rc-update add hald default\`"
	echo
	elog "Looking for automounting support? Add yourself to the plugdev group"

	elog "IF you have additional applications which consume ACPI events, you"
	elog "should consider installing acpid to allow applications to share ACPI"
	elog "events."

	elog "If you wish to use a non US layout, you may do so by executing:"
	elog "setxkbmap <layout> or by utilizing your Desktop Environment's"
	elog "Keyboard Layout Settings mechanism."
	elog "Under GNOME, this is gnome-keyboard-properties, and under KDE"
	elog "it is kxkb."
}
