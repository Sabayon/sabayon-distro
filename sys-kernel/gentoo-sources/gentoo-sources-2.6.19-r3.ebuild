# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/gentoo-sources/gentoo-sources-2.6.19-r1.ebuild,v 1.2 2006/12/02 09:40:33 corsair Exp $

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="3"
inherit kernel-2
detect_version
detect_arch

SL_PATCHES_URI="http://www.sabayonlinux.org/distfiles/sys-kernel/${PN}/ipw3945-1.1.3-2.6.19.patch"

SUSPEND2_VERSION="2.2.9"
SUSPEND2_TARGET="2.6.19-rc6"
SUSPEND2_SRC="suspend2-${SUSPEND2_VERSION}-for-${SUSPEND2_TARGET}"
SUSPEND2_URI="http://www.suspend2.net/downloads/all/${SUSPEND2_SRC}.patch.bz2"

UNIPATCH_LIST="
		${DISTDIR}/${SUSPEND2_SRC}.patch.bz2 ${DISTDIR}/ipw3945-1.1.3-2.6.19.patch
		${FILESDIR}/ata-early-irq.patch ${FILESDIR}/fuse-2.6.1.patch ${FILESDIR}/toshiba-bluetooth.patch
		"
UNIPATCH_STRICTORDER="yes"

KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
HOMEPAGE="http://dev.gentoo.org/~dsd/genpatches http://www.sabayonlinux.org"

DESCRIPTION="Full sources including the Gentoo patchset and SabayonLinux ones for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${SUSPEND2_URI} ${SL_PATCHES_URI}"

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "This is a modified version of the Gentoo's gentoo-sources. Please report problems to us first."
	einfo "http://bugs.sabayonlinux.org"
}
