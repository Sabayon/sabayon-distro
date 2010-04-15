# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit base autotools

DESCRIPTION="Linux user space daemon and config tool for Intel Enhanced Ethernet for the Data Center"
HOMEPAGE="http://e1000.sourceforge.net"
SRC_URI="mirror://sourceforge/project/e1000/DCB%20Tools/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="kernel_linux"

COMMON_DEPEND="dev-libs/libconfig
	>=sys-libs/glibc-2.10.1"
DEPEND="${COMMON_DEPEND}
	kernel_linux? ( >=sys-kernel/linux-headers-2.6.29 )"
RDEPEND="${COMMON_DEPEND}"

PATCHES=( "${FILESDIR}"/dcbd-0.9.7-make.patch
	"${FILESDIR}"/dcbd-0.9.7-init.patch
	"${FILESDIR}"/dcbd-0.9.19-init-lsb.patch
	"${FILESDIR}"/${P}-fix-if_nameindex-already-defined.patch )

src_install() {
	base_src_install
	rm "${D}"/etc/init.d/dcbd || die "cannot remove dcbd init script"
	doinitd ${FILESDIR}/dcbd
}
