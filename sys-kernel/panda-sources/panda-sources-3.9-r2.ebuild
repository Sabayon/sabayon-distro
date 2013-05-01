# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_SABKERNEL_NAME="panda"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_SABKERNEL_ALT_CONFIG_FILE="${K_SABKERNEL_SELF_TARBALL_NAME}-${PV}-armv7.config"
K_KERNEL_NEW_VERSIONING="1"
inherit sabayon-kernel
KEYWORDS="~arm"
DESCRIPTION="Sabayon PandaBoard OMAP4 Linux Kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-panda-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-panda-${PVR} )"
