# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit linux-info eutils autotools-utils base

DESCRIPTION="Tool for controlling Logitech 5x00 keyboard LCD"
HOMEPAGE="http://download.gna.org/mx5000tools/"
SRC_URI="http://download.gna.org/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/netpbm"
RDEPEND="${DEPEND}"

CONFIG_CHECK="~USB_HIDDEV"
ERROR_USB_HIDDEN="You need to the CONFIG_USB_HIDDEV option turned on."

src_prepare() {
	epatch "${FILESDIR}/${P}-netpbmfix.patch"
	eautoreconf
}
