# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="6"
IUSE="ultra1"
inherit kernel-2
inherit eutils
detect_version
detect_arch
R4V="17-3"
GPATCHVER="17"
KEYWORDS="amd64 x86"

HOMEPAGE="http://gentoo-wiki.com/HOWTO_Reiser4_With_Gentoo-Sources"
DESCRIPTION="Full sources including the gentoo patchset and the reiser4 patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}
ftp://ftp.namesys.com/pub/reiser4-for-${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}.${GPATCHVER}/reiser4-for-${KV_MAJOR}.${KV_MINOR}.${R4V}.patch.gz"

UNIPATCH_LIST="${DISTDIR}/genpatches-${KV_MAJOR}.${KV_MINOR}.${GPATCHVER}-${K_GENPATCHES_VER}.base.tar.bz2
${DISTDIR}/genpatches-${KV_MAJOR}.${KV_MINOR}.${GPATCHVER}-${K_GENPATCHES_VER}.extras.tar.bz2
${DISTDIR}/reiser4-for-${KV_MAJOR}.${KV_MINOR}.${R4V}.patch.gz"


pkg_postinst() {
 postinst_sources

 echo

 einfo "This is experimental. Make sure you enable deflate algorithm in"
 einfo "kernel encryption sub-section and make sure 8kb stacks are off in"
 einfo "the kernel hacking section."
 einfo "For more info on this patchset, and how to report problems, see:"
 einfo "${HOMEPAGE}"
}

