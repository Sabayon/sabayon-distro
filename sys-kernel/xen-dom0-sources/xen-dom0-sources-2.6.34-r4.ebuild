# Copyright 2004-2011 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
UNIPATCH_STRICTORDER="1"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="13"
K_SABKERNEL_NAME="xen"
K_SABKERNEL_NAME="xen-dom0"
K_ONLY_SOURCES="1"

inherit sabayon-kernel

# Also see:
# http://ec2-downloads.s3.amazonaws.com/user_specified_kernels.pdf

############################################
# upstream part

DESCRIPTION="Xen dom0 Linux Kernel sources suitable for running on Xen and Amazon EC2"
HOMEPAGE="http://xen.org/"
IUSE=""

KEYWORDS="~x86 ~amd64"

XENPATCHES_VER="5"
XENPATCHES="xen-patches-${PV}-${XENPATCHES_VER}.tar.bz2"
XENPATCHES_URI="http://gentoo-xen-kernel.googlecode.com/files/${XENPATCHES}"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${XENPATCHES_URI}"

UNIPATCH_LIST="${DISTDIR}/${XENPATCHES}"

DEPEND="${DEPEND} >=sys-devel/binutils-2.17"

# upstream part
############################################
