# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_SABKERNEL_SELF_TARBALL_NAME="beagleboard"
K_REQUIRED_LINUX_FIRMWARE_VER="20111025"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_MKIMAGE_RAMDISK_ADDRESS="0x81000000"
K_MKIMAGE_RAMDISK_ENTRYPOINT="0x00000000"
inherit sabayon-kernel

KEYWORDS="~arm"
DESCRIPTION="Sabayon BeagleBoard/BeagleBone/OMAP Linux kernel and modules"
RESTRICT="mirror"
DEPEND="${DEPEND} app-arch/lzop"
