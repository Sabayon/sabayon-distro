# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.27.2.1-r4.ebuild,v 1.2 2009/11/12 19:43:39 pva Exp $

inherit versionator

# Upstream uses string to version their releases. To make portage version
# comparisment working we have to use numbers instead of strings, that is 4th
# component of our version. So we have aivazovsky - 1, briullov - 2 and so on.
# Keep this string on top since we have to modify it each new release.
OVZ_CODENAME="briullov"
OVZ_CODENAME_SUBRELEASE=$(get_version_component_range 5)

OVZ_KV="${OVZ_CODENAME}.${OVZ_CODENAME_SUBRELEASE}"

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

K_SABKERNEL_NAME="openvz"
inherit sabayon-kernel

SLOT=${CKV}-${OVZ_KV}
if [[ ${PR} != r0 ]]; then
	SLOT+=-${PR}
fi

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Linux Kernel binaries with OpenVZ patchset"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/${CKV}/${CKV}-${OVZ_KV}/patches/patch-${OVZ_KV}-combined.gz                                                                                 
	mirror://gentoo/linux-2.6.27-openvz-2.6.27.39-merge.patch.bz2"

S_PN="openvz-sources"
UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-${OVZ_KV}-combined.gz
${DISTDIR}/linux-2.6.27-openvz-2.6.27.39-merge.patch.bz2"

K_EXTRAEINFO="For more information about this kernel take a look at:
http://wiki.openvz.org/Download/kernel/${CKV}/${CKV}-${OVZ_KV}"

############################################
# binary part

# Sabayon patches
UNIPATCH_LIST="${UNIPATCH_LIST}
${FILESDIR}/sabayon/4200_fbcondecor-0.9.4.patch
${FILESDIR}/sabayon/4300_squashfs-3.4.patch
"

DEPEND="${DEPEND}
	<sys-kernel/genkernel-3.4.11
	splash? ( x11-themes/sabayon-artwork-core )"
RDEPEND="grub? ( sys-boot/grub sys-boot/grub-handler )"

KV_FULL=${KV_FULL/linux/openvz}
MY_KERNEL_DIR="/usr/src/linux-${KV_FULL}"
KV_OUT_DIR="${MY_KERNEL_DIR}"
K_NOSETEXTRAVERSION="1"
EXTRAVERSION=${EXTRAVERSION/linux/openvz}
S="${WORKDIR}/linux-${KV_FULL}"

pkg_postinst() {
	sabayon-kernel_pkg_postinst

	elog "The OpenVZ Linux kernel source code is located at"
	elog "=sys-kernel/openvz-sources-${PVR}."
	elog "Sabayon Linux recommends that portage users install"
	elog "sys-kernel/openvz-sources-${PVR} if you want"
	elog "to build any packages that install kernel modules"
	elog "(such as ati-drivers, nvidia-drivers, virtualbox, etc...)."

	elog "You can find OpenVZ templates at:"
	elog "http://wiki.openvz.org/Download/template/precreated"

}


