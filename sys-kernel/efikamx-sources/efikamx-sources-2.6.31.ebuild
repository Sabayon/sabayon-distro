# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

K_SABKERNEL_SELF_TARBALL_NAME="efikamx"
K_SABKERNEL_NAME="efikamx"
K_ONLY_SOURCES="1"
K_SABKERNEL_ALT_CONFIG_FILE="${K_SABKERNEL_SELF_TARBALL_NAME}-${PV}-arm.config"
K_SABKERNEL_RESET_EXTRAVERSION="1"
K_KERNEL_PATCH_HOTFIXES="${FILESDIR}/linux-2.6-make-3.82.patch"
inherit sabayon-kernel
KEYWORDS="~arm"
DESCRIPTION="Sabayon Efika MX Legacy Linux Kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-efikamx-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-efikamx-${PVR} )"
