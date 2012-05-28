# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
SPL_TARGET="userspace"

inherit eutils linux-info spl-snapshot

EGIT_COMMIT="1997caf825ebdc3dfdd2eda096d914d829c0f730"

src_prepare() {
	spl-snapshot_src_prepare
	cd "${S}"
	kernel_is ge 3 3 0 && epatch "${FILESDIR}/${P}-linux-3.4.patch"
}
