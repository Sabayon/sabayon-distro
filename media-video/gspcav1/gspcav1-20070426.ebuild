# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/gspcav1/gspcav1-20060925.ebuild,v 1.1 2006/10/22 15:25:45 kingtaco Exp $

inherit linux-mod

DESCRIPTION="gspcav1 driver for webcams."
HOMEPAGE="http://mxhaard.free.fr/download.html"
SRC_URI="http://mxhaard.free.fr/spca50x/Download/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""
RESTRICT=""
DEPEND=""
RDEPEND=""

MODULE_NAMES="gspca(usb/video:)"
BUILD_TARGETS="default"
CONFIG_CHECK="VIDEO_DEV"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_unpack() {
	unpack ${A}
	convert_to_m ${S}/Makefile
}

src_install() {
	dodoc changelog
	linux-mod_src_install
}
