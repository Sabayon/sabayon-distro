# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_NAME="sabayon"
K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_KERNEL_NEW_VERSIONING="1"
K_SABKERNEL_PATCH_UPSTREAM_TARBALL="1"

inherit sabayon-kernel

KEYWORDS="~amd64"
DESCRIPTION="Official Sabayon Linux Standard kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-sabayon-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-sabayon-${PVR} )"
