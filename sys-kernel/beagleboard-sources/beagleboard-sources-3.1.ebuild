# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_SABKERNEL_NAME="beagleboard"
K_SABKERNEL_URI_CONFIG="yes"
K_SABKERNEL_SELF_TARBALL_NAME="beagleboard"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
inherit sabayon-kernel
KEYWORDS="~arm"
DESCRIPTION="Sabayon BeagleBoard/BeagleBone/OMAP sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-sabayon-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-sabayon-${PVR} )"

