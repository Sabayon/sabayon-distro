# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.32.39.3.ebuild,v 1.2 2011/10/21 09:28:34 pva Exp $

inherit versionator

OVZ_KV="0$(get_version_component_range 4).$(get_version_component_range 5)"


CKV=$(get_version_component_range 1-3)
OKV=${OKV:-${CKV}}
EXTRAVERSION=-${PN/-*}-${OVZ_KV}
KV_FULL=${CKV}${EXTRAVERSION}
if [[ ${PR} != r0 ]]; then
	KV_FULL+=-${PR}
	EXTRAVERSION+=-${PR}
fi

# ${KV_MAJOR}.${KV_MINOR}.${KV_PATCH} should succeed.
KV_MAJOR=$(get_version_component_range 1 ${OKV})
KV_MINOR=$(get_version_component_range 2 ${OKV})
KV_PATCH=$(get_version_component_range 3 ${OKV})

KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"

K_KERNEL_SOURCES_PKG="sys-kernel/openvz-sources-${PVR}"
K_KERNEL_DISABLE_PR_EXTRAVERSION="0"
K_WORKAROUND_SOURCES_COLLISION="1"
inherit sabayon-kernel

SLOT=${CKV}-${OVZ_KV}
if [[ ${PR} != r0 ]]; then
	SLOT+=-${PR}
fi

KEYWORDS="~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DESCRIPTION="Kernel binaries with OpenVZ patchset"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/rhel6-${CKV}/042stab${OVZ_KV}/patches/patch-042stab${OVZ_KV}-combined.gz"

UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-042stab${OVZ_KV}-combined.gz"

K_EXTRAEINFO="This openvz kernel uses RHEL6 patchset instead of vanilla kernel.
This patchset considered to be more stable and security supported by upstream,
but for us RHEL6 patchset is very fragile and fails to build in many
configurations so if you have problems use config files from openvz team
http://wiki.openvz.org/Download/kernel/rhel6/042stab${OVZ_KV}"

############################################
# binary part

# Sabayon patches
UNIPATCH_LIST="${UNIPATCH_LIST}
${FILESDIR}/sabayon-2.6.32/4200_fbcondecor-0.9.6-2.patch
${FILESDIR}/hotfixes/2.6.32/2.6.32.39.10-invalidate_inodes-macro-fix.patch
${FILESDIR}/hotfixes/2.6.32/linux-openvz-2.6.32.39.11-gcc46.patch"

pkg_postinst() {
        sabayon-kernel_pkg_postinst

        elog "You can find OpenVZ templates at:"
        elog "http://wiki.openvz.org/Download/template/precreated"

}
