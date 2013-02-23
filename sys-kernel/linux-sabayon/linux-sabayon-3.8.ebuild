# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_REQUIRED_LINUX_FIRMWARE_VER="20130113"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_SABKERNEL_ZFS="1"
K_KERNEL_NEW_VERSIONING="1"
inherit sabayon-kernel

KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Standard kernel image"
RESTRICT="mirror"
