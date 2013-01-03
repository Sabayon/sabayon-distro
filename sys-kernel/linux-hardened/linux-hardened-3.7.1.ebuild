# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2

K_SABKERNEL_SELF_TARBALL_NAME="hardened"
K_SABKERNEL_NAME="hardened"
K_KERNEL_SOURCES_PKG="sys-kernel/hardened-sources-${PVR}"
K_REQUIRED_LINUX_FIRMWARE_VER="20120924"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_KERNEL_NEW_VERSIONING="1"
inherit sabayon-kernel

KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Hardened kernel image"
RESTRICT="mirror"
