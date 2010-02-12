# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/vserver-sources/vserver-sources-2.3.0.36.28.ebuild,v 1.1 2010/01/14 09:46:54 hollow Exp $

# DEV NOTES:
# - based on sys-kernel/linux-server plus:
#   - Linux VServer options enabled
#   - More Security frameworks enabled by default

ETYPE="sources"
CKV="2.6.32"
K_USEPV="1"
K_NOSETEXTRAVERSION="1"
UNIPATCH_STRICTORDER="1"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="2"
K_SABKERNEL_NAME="vserver"
inherit sabayon-kernel

############################################
# upstream part

MY_PN="vserver-patches"

KEYWORDS="~amd64 ~hppa ~x86"
IUSE=""

DESCRIPTION="Full sources including Gentoo and Linux-VServer patchsets for the ${KV_MAJOR}.${KV_MINOR} kernel tree."
HOMEPAGE="http://www.gentoo.org/proj/en/vps/"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}
	http://dev.gentoo.org/~hollow/distfiles/${MY_PN}-${CKV}_${PVR}.tar.bz2"

UNIPATCH_LIST="${DISTDIR}/${MY_PN}-${CKV}_${PVR}.tar.bz2"

# upstream part
############################################

