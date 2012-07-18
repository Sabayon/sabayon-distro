# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_SABKERNEL_NAME="beagle"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_SABKERNEL_ALT_CONFIG_FILE="${K_SABKERNEL_SELF_TARBALL_NAME}-${PV}-beagle+panda.config"
inherit sabayon-kernel
KEYWORDS="~arm"
DESCRIPTION="Sabayon BeagleBoard (not yet Bone) OMAP3 Linux Kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-beagle-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-beagle-${PVR} )"
