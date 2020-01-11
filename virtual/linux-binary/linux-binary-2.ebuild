# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Linux kernel binaries"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

SABAYON_BINARIES="sys-kernel/linux-sabayon:4.4 sys-kernel/linux-sabayon:4.9 sys-kernel/linux-sabayon:4.14 sys-kernel/linux-sabayon:4.19 sys-kernel/linux-sabayon:4.20 sys-kernel/linux-sabayon:5.3 sys-kernel/linux-sabayon:5.4"
RDEPEND="|| (
	${SABAYON_BINARIES}
)"
DEPEND=""
