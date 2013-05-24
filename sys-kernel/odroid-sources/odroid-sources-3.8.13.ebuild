# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_URI_CONFIG="yes"
K_SABKERNEL_SELF_TARBALL_NAME="odroid"
K_SABKERNEL_NAME="odroid"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_KERNEL_NEW_VERSIONING="1"
K_ONLY_SOURCES="1"

inherit sabayon-kernel

KEYWORDS="~arm"
DESCRIPTION="Linux kernel sources for the Odroid {U,X}{2,} boards"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-efikamx-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-efikamx-${PVR} )"


src_unpack() {
	sabayon-kernel_src_unpack
	# Fix invalid kernel config path
	mv "${S}"/sabayon/config/odroid-3.8-armv7{l,}.config || die
}
