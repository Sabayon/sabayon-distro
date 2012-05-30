# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

SPL_GIT_REPO="git://github.com/ryao/spl.git"
SPL_GIT_BRANCH="gentoo"
SPL_GIT_COMMIT="1997caf825ebdc3dfdd2eda096d914d829c0f730"

ZFS_GIT_REPO="git://github.com/ryao/zfs.git"
ZFS_GIT_BRANCH="gentoo"
ZFS_GIT_COMMIT="bfdb599a767c2d86b4fcb4fe1c0a2b4314599d2f"

inherit eutils linux-info spl-zfs-userspace

src_prepare() {
	spl-zfs-userspace_src_prepare
	cd "${ZFS_S}" && \
		kernel_is gt 3 3 0 && epatch "${FILESDIR}/zfs-${PV}-linux-3.4.patch"
	cd "${SPL_S}" && \
		kernel_is gt 3 3 0 && epatch "${FILESDIR}/spl-${PV}-linux-3.4.patch"
}
