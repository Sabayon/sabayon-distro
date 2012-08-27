# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

K_SABPATCHES_VER="12"
K_KERNEL_PATCH_VER="10"
K_KERNEL_SOURCES_PKG="sys-kernel/server-sources-${PVR}"
K_SABKERNEL_URI_CONFIG="yes"
K_SABKERNEL_LONGTERM="1"
inherit sabayon-kernel
KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Server kernel image"
RESTRICT="mirror"
