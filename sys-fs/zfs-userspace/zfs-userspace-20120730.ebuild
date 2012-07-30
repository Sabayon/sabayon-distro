# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

SPL_GIT_REPO="git://github.com/ryao/spl.git"
SPL_GIT_BRANCH="gentoo"
SPL_GIT_COMMIT="ab05695dad1f13ff037bbb7376e6207d62248888"

ZFS_GIT_REPO="git://github.com/ryao/zfs.git"
ZFS_GIT_BRANCH="gentoo"
ZFS_GIT_COMMIT="4ab8a725ce8a2bcf26a9df6902f8ee893e62fe6e"

inherit eutils linux-info spl-zfs-userspace

src_prepare() {
	spl-zfs-userspace_src_prepare
	cd "${ZFS_S}" && \
		kernel_is gt 3 3 0 && epatch "${FILESDIR}/zfs-${PV}-linux-3.4.patch"
	cd "${SPL_S}" && \
		kernel_is gt 3 3 0 && epatch "${FILESDIR}/spl-${PV}-linux-3.4.patch"
}
