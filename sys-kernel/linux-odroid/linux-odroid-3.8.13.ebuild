# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_NAME="odroid"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_SABKERNEL_SELF_TARBALL_NAME="odroid"

K_MKIMAGE_RAMDISK_ADDRESS="0"
K_MKIMAGE_RAMDISK_ENTRYPOINT="0"

K_KERNEL_SOURCES_PKG="sys-kernel/odroid-sources-${PVR}"
K_KERNEL_NEW_VERSIONING="1"
K_REQUIRED_LINUX_FIRMWARE_VER="20130421"
K_KERNEL_IMAGE_NAME="zImage"
K_KERNEL_IMAGE_PATH="arch/arm/boot/zImage"

inherit sabayon-kernel

KEYWORDS="~arm"
DESCRIPTION="Linux kernel binaries for the Odroid {U,X}{2,} boards"

src_unpack() {
	sabayon-kernel_src_unpack
	# Fix invalid kernel config path
	mv "${S}"/sabayon/config/odroid-3.8-armv7{l,}.config || die
}
