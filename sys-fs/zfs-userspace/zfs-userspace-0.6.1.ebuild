# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

SPL_GIT_REPO="git://github.com/zfsonlinux/spl.git"
SPL_GIT_BRANCH="master"
SPL_GIT_COMMIT="spl-0.6.1"

ZFS_GIT_REPO="git://github.com/zfsonlinux/zfs.git"
ZFS_GIT_BRANCH="master"
ZFS_GIT_COMMIT="zfs-0.6.1"

inherit eutils linux-info spl-zfs-userspace

src_prepare() {
	spl-zfs-userspace_src_prepare
}
