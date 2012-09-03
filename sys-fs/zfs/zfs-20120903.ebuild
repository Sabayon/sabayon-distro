# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

SPL_GIT_REPO="git://github.com/zfsonlinux/spl.git"
SPL_GIT_BRANCH="master"
SPL_GIT_COMMIT="ac8ca67a88bdb8be08456785116a8824fba735df"

ZFS_GIT_REPO="git://github.com/zfsonlinux/zfs.git"
ZFS_GIT_BRANCH="master"
ZFS_GIT_COMMIT="ba7dbeb22e4b0f2d4c2b805abfee8d663e0f779d"

inherit eutils linux-info spl-zfs-kernel

src_prepare() {
	spl-zfs-kernel_src_prepare
}
