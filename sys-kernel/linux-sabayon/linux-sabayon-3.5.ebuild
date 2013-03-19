# Copyright 2004-2010 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_REQUIRED_LINUX_FIRMWARE_VER="20120219"
K_SABKERNEL_FORCE_SUBLEVEL="0"
inherit sabayon-kernel

KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Standard kernel image"
RESTRICT="mirror"

src_unpack() {
	sabayon-kernel_src_unpack
	sed -i "s:CONFIG_AUFS_FS=m:CONFIG_AUFS_FS=y:" "${S}"/sabayon/config/*.config || die
}
