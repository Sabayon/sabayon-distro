# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib

EAPI="2"

DESCRIPTION="xvba-video"
HOMEPAGE="http://www.splitted-desktop.com/~gbeauchesne/xvba-video/"
SRC_URI="x86? ( http://www.splitted-desktop.com/~gbeauchesne/${PN}/${P}.i686.tar.gz )
	amd64? ( http://www.splitted-desktop.com/~gbeauchesne/${PN}/${P}.x86_64.tar.gz )"

LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-libs/libva"
RDEPEND="${DEPEND}
	>=x11-drivers/ati-drivers-9.10"

use x86 && S=${P}.i686
use amd64 && S=${P}.x86_64

QA_PRESTRIPPED=usr/$(get_libdir)/va/drivers/xvba_drv_video.so

src_install() {
	cd ${S}
	insinto usr/$(get_libdir)/va/drivers
	doins usr/lib/va/drivers/xvba_drv_video.so
	dosym xvba_drv_video.so usr/$(get_libdir)/va/drivers/fglrx_drv_video.so
}
