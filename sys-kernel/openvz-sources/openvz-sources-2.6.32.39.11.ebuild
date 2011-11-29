# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.32.39.3.ebuild,v 1.2 2011/10/21 09:28:34 pva Exp $

inherit versionator

OVZ_KV="0$(get_version_component_range 4).$(get_version_component_range 5)"

ETYPE="sources"

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

inherit kernel-2
detect_version

KEYWORDS="~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DESCRIPTION="Kernel sources with OpenVZ patchset"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/rhel6-${CKV}/042stab${OVZ_KV}/patches/patch-042stab${OVZ_KV}-combined.gz"

UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-042stab${OVZ_KV}-combined.gz
	${FILESDIR}/2.6.32.39.10-invalidate_inodes-macro-fix.patch"

K_EXTRAEINFO="This openvz kernel uses RHEL6 patchset instead of vanilla kernel.
This patchset considered to be more stable and security supported by upstream,
but for us RHEL6 patchset is very fragile and fails to build in many
configurations so if you have problems use config files from openvz team
http://wiki.openvz.org/Download/kernel/rhel6/042stab${OVZ_KV}"
