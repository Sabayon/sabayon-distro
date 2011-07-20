# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"
UNIPATCH_STRICTORDER="1"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="10"
K_SABKERNEL_NAME="xen"
inherit sabayon-kernel

############################################
# upstream part

DESCRIPTION="Full sources for a dom0/domU Linux kernel to run under Xen"
HOMEPAGE="http://xen.org/"
IUSE=""

# FIXME: this ebuild is broken because Genkernel
# does not support building Xen kernels
# KEYWORDS="~x86 ~amd64"
KEYWORDS=""

XENPATCHES_VER="10"
XENPATCHES="xen-patches-${PV}-${XENPATCHES_VER}.tar.bz2"
XENPATCHES_URI="http://gentoo-xen-kernel.googlecode.com/files/${XENPATCHES}"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${XENPATCHES_URI}"

UNIPATCH_LIST="${DISTDIR}/${XENPATCHES}"

DEPEND="${DEPEND} >=sys-devel/binutils-2.17"

# upstream part
############################################




