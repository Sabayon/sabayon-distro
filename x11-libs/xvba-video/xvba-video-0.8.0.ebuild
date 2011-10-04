# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit base

DESCRIPTION="xvba-video"
HOMEPAGE="http://www.splitted-desktop.com/~gbeauchesne/xvba-video/"
SRC_URI="http://www.splitted-desktop.com/~gbeauchesne/xvba-video/${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="x11-libs/libva
	virtual/opengl"
DEPEND="${COMMON_DEPEND}
	>=x11-drivers/ati-userspace-10.12"
RDEPEND="${DEPEND}"

src_configure() {
	base_src_configure --enable-libxvba-dlopen \
		--enable-glx
}

pkg_postinst() {
	echo
	elog "This version of xvba-video requires >=x11-drivers/ati-drivers-10.12"
	elog "at runtime."
	echo
}
