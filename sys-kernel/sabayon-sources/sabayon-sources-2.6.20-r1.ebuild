# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
inherit kernel-2
detect_version
detect_arch

SL_PATCHES_URI="
		http://www.sabayonlinux.org/distfiles/sys-kernel/gentoo-sources/ipw3945-1.2.0-${PV/_*}.patch
		http://www.sabayonlinux.org/distfiles/sys-kernel/gentoo-sources/squashfs-3.2-2.6.20.patch
		http://dev.gentoo.org/~spock/projects/gensplash/archive/fbsplash-0.9.2-r5-2.6.19-rc2.patch
		"

SUSPEND2_VERSION="2.2.9.3"
SUSPEND2_TARGET="2.6.20-rc4"
SUSPEND2_SRC="suspend2-${SUSPEND2_VERSION}-for-${SUSPEND2_TARGET}"
SUSPEND2_URI="http://www.suspend2.net/downloads/all/${SUSPEND2_SRC}.patch.bz2"

UNIPATCH_LIST="
		${DISTDIR}/${SUSPEND2_SRC}.patch.bz2 ${DISTDIR}/ipw3945-1.2.0-${PV/_*}.patch
		${DISTDIR}/fbsplash-0.9.2-r5-2.6.19-rc2.patch ${DISTDIR}/squashfs-3.2-2.6.20.patch
		${FILESDIR}/2.6.20-mactel.patch ${FILESDIR}/${P}-wireless-dev.patch
		${FILESDIR}/${P}-cx88-tvaudio-fixes.patch ${FILESDIR}/${P}-unionfs-2.0.diff
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
