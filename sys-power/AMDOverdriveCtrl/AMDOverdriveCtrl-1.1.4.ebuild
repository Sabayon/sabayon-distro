# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

WX_GTK_VER="2.8"
inherit wxwidgets

DESCRIPTION="AMD Overclocking Utility"
HOMEPAGE="http://amdovdrvctrl.sourceforge.net"
SRC_URI="mirror://sourceforge/amdovdrvctrl/${PN}.${PV}.tar.bz2
	http://download2-developer.amd.com/amd/GPU/zip/ADL_SDK_3.0.zip"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-drivers/ati-drivers
	x11-libs/wxGTK:${WX_GTK_VER}[X]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${PN}.${PV}.tar.bz2
	cd ${PN}/ADL_SDK
	unpack ADL_SDK_3.0.zip
}
