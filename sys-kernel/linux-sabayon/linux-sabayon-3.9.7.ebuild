# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_REQUIRED_LINUX_FIRMWARE_VER="20130421"
K_SABKERNEL_FORCE_SUBLEVEL="0"
if ! use arm; then
	K_SABKERNEL_ZFS="1"
else
	K_KERNEL_IMAGE_NAME="uImage dtbs"
fi
K_KERNEL_NEW_VERSIONING="1"

K_MKIMAGE_RAMDISK_ADDRESS="0x81000000"
K_MKIMAGE_RAMDISK_ENTRYPOINT="0x00000000"
K_MKIMAGE_KERNEL_ADDRESS="0x80008000"

inherit sabayon-kernel

KEYWORDS="~amd64 ~arm ~x86"
DESCRIPTION="Official Sabayon Linux Standard kernel image"
RESTRICT="mirror"
