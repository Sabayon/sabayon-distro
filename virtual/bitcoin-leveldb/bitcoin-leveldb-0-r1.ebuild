# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Virtual for LevelDB versions known to be compatible with Bitcoin Core 0.9+"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~ppc ~ppc64 x86 amd64-linux x86-linux"

# added 1.18-r2
# https://bugs.gentoo.org/show_bug.cgi?id=627752

RDEPEND="
	|| (
		=dev-libs/leveldb-1.18-r2
		=dev-libs/leveldb-1.18-r1
		=dev-libs/leveldb-1.18
		=dev-libs/leveldb-1.17
		=dev-libs/leveldb-1.15.0-r1
	)"
