# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_KERNEL_SOURCES_PKG="sys-kernel/panda-sources-${PVR}"
K_REQUIRED_LINUX_FIRMWARE_VER="20111025"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_MKIMAGE_RAMDISK_ADDRESS="0x81000000"
K_MKIMAGE_RAMDISK_ENTRYPOINT="0x00000000"
K_SABKERNEL_ALT_CONFIG_FILE="${EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME}-${PV}-pandaboard.config"
inherit sabayon-kernel
KEYWORDS="~arm"
DESCRIPTION="Sabayon PandaBoard OMAP4 Linux Kernel and modules"
RESTRICT="mirror"
