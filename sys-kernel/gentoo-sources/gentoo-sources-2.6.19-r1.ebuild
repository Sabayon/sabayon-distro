# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/gentoo-sources/gentoo-sources-2.6.19-r1.ebuild,v 1.2 2006/12/02 09:40:33 corsair Exp $

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="2"
inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
HOMEPAGE="http://www.sabayonlinux.org"

DESCRIPTION="Full sources including the Gentoo patchset and SabayonLinux ones for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"

src_unpack() {

        kernel-2_src_unpack

        # ipw3945 support
        epatch ${FILESDIR}/ipw3945-1.1.3-2.6.19.patch

}


pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "This is a modified version of the Gentoo's gentoo-sources. Please report problems to us first."
	einfo "http://bugs.sabayonlinux.org"
}
