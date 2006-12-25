# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/gspca/gspca-01.00.10.ebuild,v 1.1 2006/12/25 08:23:16 kingtaco Exp $

inherit linux-mod

S="${WORKDIR}/gspcav1-${PV}"
DESCRIPTION="gspca driver for webcams."
HOMEPAGE="http://mxhaard.free.fr/spca5xx.html"
#http://mxhaard.free.fr/spca50x/Investigation/Gspca/gspcav1-01.00.10.tar.gz
SRC_URI="http://mxhaard.free.fr/spca50x/Investigation/Gspca/gspcav1-${PV}.tar.gz"
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
	S="${WORKDIR}/${P}/gspcav2"
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_unpack() {
	unpack ${A}
	convert_to_m ${S}/Makefile
	cd "${S}"
	epatch "${FILESDIR}"/gspca-20060813-defines.patch
}