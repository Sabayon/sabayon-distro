# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

K_SABKERNEL_NAME="beaglebone"
K_SABKERNEL_URI_CONFIG="yes"
K_SABKERNEL_SELF_TARBALL_NAME="beaglebone"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
inherit sabayon-kernel
KEYWORDS="~arm"
DESCRIPTION="Sabayon BeagleBone OMAP3 Linux Kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}"
#	sources_standalone? ( !=sys-kernel/linux-beagleboard-${PVR} )
#	!sources_standalone? ( =sys-kernel/linux-beagleboard-${PVR} )"

