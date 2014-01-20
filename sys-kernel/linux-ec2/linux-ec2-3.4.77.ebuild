# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_KERNEL_SOURCES_PKG="sys-kernel/ec2-sources-${PVR}"
K_REQUIRED_LINUX_FIRMWARE_VER="20130728"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_KERNEL_NEW_VERSIONING="1"
inherit sabayon-kernel
KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Sabayon Linux kernel image for Amazon EC2"
RESTRICT="mirror"

pkg_postinst() {
	default
	elog "This is the last 3.4 LTS version offered by Sabayon."
	elog "Please migrate to 3.10 LTS kernels, like for instance:"
	elog "- sys-kernel/linux-sabayon:3.10"
}
