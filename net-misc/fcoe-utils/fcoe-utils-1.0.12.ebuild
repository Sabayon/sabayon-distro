# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

EGIT_REPO_URI="git://open-fcoe.org/openfc/${PN}.git"
EGIT_COMMIT="v${PV}"
inherit base git autotools linux-info

DESCRIPTION="Fibre Channel over Ethernet utilities"
HOMEPAGE="http://www.open-fcoe.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+dcb kernel_linux"

DEPEND="sys-apps/hbaapi
	dcb? ( >=net-misc/dcbd-0.9.24 )
	kernel_linux? ( virtual/linux-sources )"
RDEPEND="sys-apps/hbaapi
	dcb? ( >=net-misc/dcbd-0.9.24 )"

PATCHES=( "${FILESDIR}/${PN}-1.0.7-init.patch"
	"${FILESDIR}/${PN}-1.0.7-init-condrestart.patch"
	"${FILESDIR}/${PN}-1.0.8-init-LSB.patch"
	"${FILESDIR}/${PN}-add-kernel-include-dir.patch"
	"${FILESDIR}/${P}-makefile-data-hook.patch"
)

src_prepare() {
	git_src_prepare
	base_src_prepare

	eautoreconf || die "failed to run eautoreconf"
}

src_configure() {
	econf $(use_with dcb) || die "cannot run configure"
}

src_compile() {
	emake KV_OUT_DIR="${KV_OUT_DIR}" || die "make failed"
}
