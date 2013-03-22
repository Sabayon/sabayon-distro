# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.32.75.2.ebuild,v 1.1 2013/03/13 08:35:44 maksbotan Exp $

EAPI="5"

inherit versionator

OVZ_KV="0$(get_version_component_range 4).$(get_version_component_range 5)"

CKV=$(get_version_component_range 1-3)
OKV=${OKV:-${CKV}}
EXTRAVERSION=-${PN/-*}-${OVZ_KV}
ETYPE="sources"
KV_FULL=${CKV}${EXTRAVERSION}
if [[ ${PR} != "r0" ]]; then
	KV_FULL+=-${PR}
	EXTRAVERSION+=-${PR}
fi
S=${WORKDIR}/linux-${KV_FULL}

# ${KV_MAJOR}.${KV_MINOR}.${KV_PATCH} should succeed.
KV_MAJOR=$(get_version_component_range 1 ${OKV})
KV_MINOR=$(get_version_component_range 2 ${OKV})
KV_PATCH=$(get_version_component_range 3 ${OKV})

KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.xz"

inherit kernel-2
#detect_version

KEYWORDS="~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DESCRIPTION="Kernel sources with OpenVZ patchset"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/rhel6-${CKV}/042stab${OVZ_KV}/patches/patch-042stab${OVZ_KV}-combined.gz"

UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-042stab${OVZ_KV}-combined.gz
	${FILESDIR}/hotfixes/2.6.32/linux-openvz-2.6.32.59.7-gcc46.patch"

K_EXTRAEINFO="This openvz kernel uses RHEL6 patchset instead of vanilla kernel.
This patchset considered to be more stable and security supported by upstream,
but for us RHEL6 patchset is very fragile and fails to build in many
configurations so if you have problems use config files from openvz team
http://wiki.openvz.org/Download/kernel/rhel6/042stab${OVZ_KV}

For info in next paragraph, see
http://bugzilla.openvz.org/show_bug.cgi?id=2012#1

In general, RHEL kernels are very sensitive to compiler version and therefore
should be compiled by RHEL compiler, otherwise there might be stability issues,
sometimes as bad as this case."

K_EXTRAEWARN="This kernel is stable only when built with gcc-4.4.x and is known
to oops in random places if built with newer compilers."
