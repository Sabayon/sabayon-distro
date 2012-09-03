# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

SPL_GIT_REPO="git://github.com/ryao/spl.git"
SPL_GIT_BRANCH="gentoo"
SPL_GIT_COMMIT="6576a1a70dedfc7d5a5e1533a9e3e56074de4c79"

ZFS_GIT_REPO="git://github.com/ryao/zfs.git"
ZFS_GIT_BRANCH="gentoo"
ZFS_GIT_COMMIT="4ab8a725ce8a2bcf26a9df6902f8ee893e62fe6e"

inherit eutils linux-info spl-zfs-kernel

src_prepare() {
	spl-zfs-kernel_src_prepare
}
