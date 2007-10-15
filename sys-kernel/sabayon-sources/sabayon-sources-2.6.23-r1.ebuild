# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
inherit kernel-2
detect_version
detect_arch

SL_PATCHES_URI="
		http://dev.gentoo.org/~spock/projects/fbcondecor/archive/fbcondecor-0.9.4-${PV}-rc7.patch
		http://download.filesystems.org/unionfs/unionfs-2.1/unionfs-2.1.6_for_2.6.23-rc8.diff.gz
"

SUSPEND2_VERSION="2.2.10.4"
SUSPEND2_TARGET="2.6.23-rc9"
SUSPEND2_SRC="tuxonice-${SUSPEND2_VERSION}-for-${SUSPEND2_TARGET}"
SUSPEND2_URI="http://www.tuxonice.net/downloads/all/${SUSPEND2_SRC}.patch.bz2"

UNIPATCH_LIST="
		${DISTDIR}/fbcondecor-0.9.4-${PV}-rc7.patch
		${FILESDIR}/${PN}-2.6.22-squashfs-3.2.patch 
		${FILESDIR}/${P}-squashfs-update.patch
		${DISTDIR}/${SUSPEND2_SRC}.patch.bz2
		${FILESDIR}/${PN}-2.6.22-ipw3945-1.2.0-2.6.22.patch 
		${FILESDIR}/${PN}-2.6.21-from-ext4dev-to-ext4.patch
		${DISTDIR}/unionfs-2.1.6_for_2.6.23-rc8.diff.gz
		${FILESDIR}/${P}-mac80211-drivers.patch
		${FILESDIR}/${P}-acx-old.patch

		${FILESDIR}/${PN}-2.6.22-mactel-appleir.patch
		${FILESDIR}/acer-acpi-2.6.23.patch
		${FILESDIR}/linux-phc-0.3.0-pre1-2.6.23.patch
		${FILESDIR}/hrtimers-2.6.23.patch
		${FILESDIR}/powertop-2.6.23.patch
		${FILESDIR}/pm_qos-2.6.23.patch
		${FILESDIR}/thinkpad-2.6.23.patch
		${FILESDIR}/mactel-patches-2.6.23.patch
		${FILESDIR}/${P}-sandbox-violation.patch
		${FILESDIR}/linux-2.6.23.1.patch
		${FILESDIR}/acpi-release-20070126-2.6.23.patch
		${FILESDIR}/rt2x00-latest-2.6.23.patch

		"
# disabled for testing
#${FILESDIR}/${PN}-2.6.22-unionfs-1.3.diff




UNIPATCH_STRICTORDER="yes"

KEYWORDS="~amd64 ~x86 ~ppc ~ppc64"
HOMEPAGE="http://www.sabayonlinux.org"

DESCRIPTION="Full sources including the Gentoo patchset and SabayonLinux ones for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${SUSPEND2_URI} ${SL_PATCHES_URI}"

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "This is a modified version of the Gentoo's gentoo-sources. Please report problems to us first."
	einfo "http://bugs.sabayonlinux.org"
}
