# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ZFS_TARGET="userspace"

inherit eutils linux-info zfs-snapshot

EGIT_COMMIT="bfdb599a767c2d86b4fcb4fe1c0a2b4314599d2f"

src_prepare() {
	zfs-snapshot_src_prepare
	cd "${S}"
	kernel_is gt 3 3 0 && epatch "${FILESDIR}/zfs-${PV}-linux-3.4.patch"
}
