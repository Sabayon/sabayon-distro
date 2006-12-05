# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/gentoo-sources/gentoo-sources-2.6.18-r2.ebuild,v 1.1 2006/11/08 14:14:43 dsd Exp $

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="3"
IUSE="ultra1"
inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
HOMEPAGE="http://dev.gentoo.org/~dsd/genpatches"

DESCRIPTION="Full sources including the gentoo patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"

pkg_setup() {
	if use sparc; then
		# hme lockup hack on ultra1
		use ultra1 || UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1705_sparc-U1-hme-lockup.patch"
	fi

}

src_unpack() {

	kernel-2_src_unpack
	cd ${S}
	epatch ${FILESDIR}/2.6.18-am2-nvidia-ati.patch
	epatch ${FILESDIR}/2.6.18-am2-nvidia-fix.patch
	epatch ${FILESDIR}/09-non-libata-driver-for-jmicron-devices.patch
	
	# 2.6.18.3
	epatch ${FILESDIR}/patch-2.6.18.2-3
	# 2.6.18.4
	epatch ${FILESDIR}/patch-2.6.18.3-4

	# ipw3945 support
	epatch ${FILESDIR}/ipw3945-1.1.3_pre2-2.6.18.patch

} 

pkg_postinst() {
	postinst_sources

	echo

	if [ "${ARCH}" = "sparc" ]; then
		if [ x"`cat /proc/openprom/name 2>/dev/null`" \
			 = x"'SUNW,Ultra-1'" ]; then
			einfo "For users with an Enterprise model Ultra 1 using the HME"
			einfo "network interface, please emerge the kernel using the"
			einfo "following command: USE=ultra1 emerge ${PN}"
		fi
	fi
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}
