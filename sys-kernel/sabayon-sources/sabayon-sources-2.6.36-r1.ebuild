# Copyright 2004-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
K_SABPATCHES_VER="3"
K_KERNEL_PATCH_VER=""
K_SABKERNEL_NAME="sabayon"
K_SABKERNEL_URI_CONFIG="yes"
K_ONLY_SOURCES="1"
K_KERNEL_PATCH_HOTFIXES="${FILESDIR}/hotfixes/2.6.36/sched_automated_per_tty_task_groups_2.6.36.patch"
inherit sabayon-kernel
KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Standard kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-sabayon-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-sabayon-${PVR} )"

