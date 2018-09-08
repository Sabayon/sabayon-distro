# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Linux kernel binaries"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"


SABAYON_BINARIES="sys-kernel/linux-sabayon:*"

RDEPEND="|| (
                ${SABAYON_BINARIES}
        )"
DEPEND="${RDEPEND}"
