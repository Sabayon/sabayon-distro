# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/zfs/zfs-9999.ebuild,v 1.18 2012/04/11 00:10:46 floppym Exp $

EAPI="4"

AT_M4DIR="config"
AUTOTOOLS_AUTORECONF="1"
AUTOTOOLS_IN_SOURCE_BUILD="1"

inherit flag-o-matic git-2 linux-mod toolchain-funcs autotools-utils

DESCRIPTION="Native ZFS for Linux"
HOMEPAGE="http://zfsonlinux.org/"
SRC_URI=""
EGIT_REPO_URI="git://github.com/ryao/zfs.git"
EGIT_BRANCH="gentoo"
EGIT_COMMIT="bfdb599a767c2d86b4fcb4fe1c0a2b4314599d2f"

LICENSE="CDDL GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="custom-cflags debug dracut +rootfs test test-suite static-libs"

DEPEND="
	~sys-kernel/spl-${PV}
	sys-apps/util-linux[static-libs?]
	sys-libs/zlib[static-libs(+)?]
"
RDEPEND="${DEPEND}
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
		)
"
DEPEND+="
	test? ( sys-fs/mdadm )
"

pkg_setup() {
	CONFIG_CHECK="!DEBUG_LOCK_ALLOC
		BLK_DEV_LOOP
		EFI_PARTITION
		MODULES
		ZLIB_DEFLATE
		ZLIB_INFLATE"
	kernel_is ge 2 6 26 || die "Linux 2.6.26 or newer required"
	check_extra_config
}

src_prepare() {
	# Workaround for hard coded path
	sed -i "s|/sbin/lsmod|/bin/lsmod|" scripts/common.sh.in || die
	# Workaround rename
	sed -i "s|/usr/bin/scsi-rescan|/usr/sbin/rescan-scsi-bus|" scripts/common.sh.in || die
	autotools-utils_src_prepare
}

src_configure() {
	use custom-cflags || strip-flags
	set_arch_to_kernel
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=all
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		--with-udevdir="${EPREFIX}/lib/udev"
		$(use_enable debug)
	)
	autotools-utils_src_configure
}

src_test() {
	if [[ $UID -ne 0 ]]
	then
		ewarn "Cannot run make check tests with FEATURES=userpriv."
		ewarn "Skipping make check tests."
	else
		autotools-utils_src_test
	fi
}

src_install() {
	autotools-utils_src_install
	gen_usr_ldscript -a uutil nvpair zpool zfs
	use dracut || rm -rf "${ED}usr/share/dracut"
	use test-suite || rm -rf "${ED}usr/libexec"

	if use rootfs
	then
		doinitd "${FILESDIR}/zfs-shutdown"
		exeinto /usr/share/zfs
		doexe "${FILESDIR}/linuxrc"
	fi

}

pkg_postinst() {
	linux-mod_pkg_postinst

	use x86 && ewarn "32-bit kernels are unsupported by ZFSOnLinux upstream. Do not file bug reports."

	[ -e "${EROOT}/etc/runlevels/boot/zfs" ] \
		|| ewarn 'You should add zfs to the boot runlevel.'

	use rootfs && ([ -e "${EROOT}/etc/runlevels/shutdown/zfs-shutdown" ] \
		|| ewarn 'You should add zfs-shutdown to the shutdown runlevel.')

}
