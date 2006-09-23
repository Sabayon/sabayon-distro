# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="9"
IUSE="ultra1"
R4V="-3"
inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://gentoo-wiki.com/HOWTO_Reiser4_With_Gentoo-Sources"

DESCRIPTION="Full sources including the gentoo patchset for the
${KV_MAJOR}.${KV_MINOR} kernel tree and the reiser4 patchset from namesys"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}
ftp://ftp.namesys.com/pub/reiser4-for-${KV_MAJOR}.${KV_MINOR}/${PV}/reiser4-for-${PV}${R4V}.patch.gz"
UNIPATCH_LIST="${DISTDIR}/reiser4-for-${PV}${R4V}.patch.gz"

pkg_postinst() {
        postinst_sources

        echo

        einfo "For more info on this patchset, see:"
        einfo "${HOMEPAGE}"
}
