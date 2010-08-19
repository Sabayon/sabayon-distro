# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_SABPATCHES_VER="6"
K_SABKERNEL_NAME="server"
K_KERNEL_SOURCES_PKG="sys-kernel/linux-server-sources-${PVR}"
inherit sabayon-kernel
KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Server kernel image"
RESTRICT="mirror"
