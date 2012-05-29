# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

AT_M4DIR="config"
AUTOTOOLS_AUTORECONF="1"
AUTOTOOLS_IN_SOURCE_BUILD="1"

inherit eutils flag-o-matic git-2 linux-mod autotools-utils

# export all the available functions here
EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_install src_test pkg_preinst pkg_postinst pkg_postrm

EGIT_REPO_URI="git://github.com/ryao/zfs.git"
EGIT_BRANCH="gentoo"
SRC_URI=""

# @ECLASS-VARIABLE: ZFS_TARGET
# @DESCRIPTION:
# Identifies either the userspace tools (="userspace")
# or the kernel module (="kernel")
ZFS_TARGET="${ZFS_TARGET:-}"

if [ "${ZFS_TARGET}" = "userspace" ]; then
	DESCRIPTION="Native ZFS for Linux Userspace utilities"
else
	DESCRIPTION="Native ZFS for the Linux Kernel"
fi

HOMEPAGE="http://zfsonlinux.org/"

LICENSE="CDDL GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=
RDEPEND=

if [ "${ZFS_TARGET}" = "kernel" ]; then
	IUSE="custom-cflags debug test"
	RDEPEND+=" ~sys-kernel/spl-${PV} ~sys-fs/zfs-userspace-${PV}"
else
	IUSE="custom-cflags debug dracut +rootfs test test-suite static-libs"
	DEPEND+=" sys-apps/util-linux[static-libs?]
		sys-libs/zlib[static-libs(+)?]"
	RDEPEND+=" ${DEPEND}
		!sys-fs/zfs-fuse
		!prefix? ( sys-fs/udev )
		test-suite? (
			sys-apps/gawk
			sys-apps/util-linux
			sys-devel/bc
			sys-block/parted
			sys-fs/lsscsi
			sys-fs/mdadm
			sys-process/procps
			virtual/modutils
			)
		rootfs? (
			app-arch/cpio
			app-misc/pax-utils
		)"
	DEPEND+=" test? ( sys-fs/mdadm )"
fi

zfs-snapshot_pkg_setup() {
	if [ "${ZFS_TARGET}" = "kernel" ]; then
		CONFIG_CHECK="!DEBUG_LOCK_ALLOC
			BLK_DEV_LOOP
			EFI_PARTITION
			MODULES
			ZLIB_DEFLATE
			ZLIB_INFLATE"
		kernel_is ge 2 6 26 || die "Linux 2.6.26 or newer required"
		check_extra_config
	fi
}

zfs-snapshot_src_prepare() {
	# Workaround for hard coded path
	sed -i "s|/sbin/lsmod|/bin/lsmod|" scripts/common.sh.in || die
	# Workaround rename
	sed -i "s|/usr/bin/scsi-rescan|/usr/sbin/rescan-scsi-bus|" scripts/common.sh.in || die
	autotools-utils_src_prepare
}

zfs-snapshot_src_configure() {
	use custom-cflags || strip-flags

	local what_config
	if [ "${ZFS_TARGET}" = "kernel" ]; then
		what_config="kernel"
		set_arch_to_kernel
	else
		what_config="user"
	fi
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config="${what_config}"
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		--with-udevdir="${EPREFIX}/lib/udev"
		$(use_enable debug)
	)
	autotools-utils_src_configure
}

zfs-snapshot_src_install() {
	autotools-utils_src_install

	if [[ "${ZFS_TARGET}" = "userspace" ]]
	then
		gen_usr_ldscript -a uutil nvpair zpool zfs
		use dracut || rm -rf "${ED}usr/share/dracut"
		use test-suite || rm -rf "${ED}usr/libexec"

		if use rootfs
		then
			doinitd "${FILESDIR}/zfs-shutdown"
			exeinto /usr/share/zfs
			doexe "${FILESDIR}/linuxrc"
		fi
	else
		rm -rf "${ED}/usr" # make sure
	fi
}

zfs-snapshot_src_test() {
	if [[ $UID -ne 0 ]]
	then
		ewarn "Cannot run make check tests with FEATURES=userpriv."
		ewarn "Skipping make check tests."
	elif [[ "${ZFS_TARGET}" = "userspace" ]]
	then
		autotools-utils_src_test
	fi
}

zfs-snapshot_pkg_preinst() {
	[[ "${ZFS_TARGET}" = "kernel" ]] && \
		linux-mod_pkg_preinst
}

zfs-snapshot_pkg_postinst() {
	[[ "${ZFS_TARGET}" = "kernel" ]] && \
		linux-mod_pkg_postinst

	use x86 && ewarn "32-bit kernels are unsupported by ZFSOnLinux upstream. Do not file bug reports."

	[[ "${ZFS_TARGET}" = "userspace" ]] && [[ -e "${EROOT}/etc/runlevels/boot/zfs" ]] \
		|| ewarn 'You should add zfs to the boot runlevel.'

	if [[ "${ZFS_TARGET}" = "userspace" ]]
	then
		use rootfs && [[ "${ZFS_TARGET}" = "userspace" ]] && \
		([ -e "${EROOT}/etc/runlevels/shutdown/zfs-shutdown" ] \
			|| ewarn 'You should add zfs-shutdown to the shutdown runlevel.')
	fi
}

zfs-snapshot_pkg_postrm() {
	[[ "${ZFS_TARGET}" = "kernel" ]] && \
		linux-mod_pkg_postrm
}
