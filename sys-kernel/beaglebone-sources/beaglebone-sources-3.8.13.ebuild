# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_NAME="beaglebone"
K_SABKERNEL_URI_CONFIG="yes"
K_SABKERNEL_SELF_TARBALL_NAME="beaglebone"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_KERNEL_NEW_VERSIONING="1"

K_KERNEL_PATCH_HOTFIXES="${FILESDIR}/${P}-config.patch"

inherit sabayon-kernel

KEYWORDS="~arm"
DESCRIPTION="Linux Kernel sources for the BeagleBone"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-beaglebone-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-beaglebone-${PVR} )"
