# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit toolchain-funcs linux-info

DESCRIPTION="Tool for controlling Logitech MX Revolution mouses"
HOMEPAGE="http://revoco.sourceforge.net/"
SRC_URI="mirror://sourceforge/revoco/revoco-${PV}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=sys-fs/udev-104"

CONFIG_CHECK="~USB_HIDDEV"
ERROR_USB_HIDDEN="You need to enable the CONFIG_USB_HIDDEV option."

src_compile() {
	$(tc-getCC) -DVERSION=\"${PV}\" ${CFLAGS} ${LDFLAGS} \
		"${S}"/${PN}.c -o "${T}"/${PN} || die "Failed to compile ${PN}"
}

src_install() {
	dobin "${T}"/${PN}
}

pkg_postinst() {
	einfo "Your user needs to be in the usb group to use revoco."
}
