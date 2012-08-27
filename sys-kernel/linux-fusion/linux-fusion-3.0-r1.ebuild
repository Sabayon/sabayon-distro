# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

K_SABKERNEL_SELF_TARBALL_NAME="fusion"
K_REQUIRED_LINUX_FIRMWARE_VER="20110709"
K_SABKERNEL_FORCE_SUBLEVEL="0"
inherit sabayon-kernel

KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux Fusion (on steroids) kernel image"
RESTRICT="mirror"

src_unpack() {
	sabayon-kernel_src_unpack
	# fixup EXTRAVERSION, we don't want anything to append stuff
	sed -i "s/^EXTRAVERSION :=.*//" "${S}/Makefile" || die
}
