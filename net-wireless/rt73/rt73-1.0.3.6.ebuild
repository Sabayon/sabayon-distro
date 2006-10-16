# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/rt61/rt61-1.1.0_beta1.ebuild,v 1.1 2006/07/01 12:12:16 genstef Exp $

inherit linux-mod

DESCRIPTION="Driver for the RaLink RT73/2571 wireless chipsets"
HOMEPAGE="http://www.ralink.com.tw"
SRC_URI="http://www.ralink.com.tw/drivers/Linux/RT73_Linux_STA_Drv${PV}.tar.gz"

MY_P=RT73_Linux_STA_Drv${PV}

# May work on other little endien arches, e.g amd64
# Known broken on big endian arches
LICENSE="GPL-2"
KEYWORDS="~x86"
IUSE="debug"

RDEPEND="net-wireless/wireless-tools"
MODULE_NAMES="rt73(net:${S}/Module)"

S=${WORKDIR}/${MY_P}

CONFIG_CHECK="NET_RADIO"
ERROR_NET_RADIO="${P} requires support for Wireless LAN drivers (non-hamradio) & Wireless Extensions (CONFIG_NET_RADIO)."
MODULESD_RT73_ALIASES=('usbra? rt73')

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNDIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"

}

src_unpack (){
	unpack ${A}
	cd "${S}/Module"

	# Portage expects to do make module, not make all
	# Only patch the makefile we are going to use

	# Makefile.4 - Makefile for kernel 2.4 series
	if kernel_is 2 4 ; then
		epatch "${FILESDIR}/make4.patch"
		cp Makefile.4 Makefile
	fi

	# Makefile.6 - Makefile for kernel 2.6 series
	if kernel_is 2 6 ; then
		epatch "${FILESDIR}/make6.patch"
		cp Makefile.6 Makefile
	fi
	if ! [ -f Makefile ]; then
		ewarn "Your kernel version is ${KV_MAJOR}.${KV_MINOR}.X"
		ewarn "this kernel version is not tested/supported"
		die
	fi

	# You can edit patch to also add your RT73 device if you are careful.
	epatch "${FILESDIR}/deviceID.patch"
}


src_compile() {
	use debug && export debug="y"
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
	dodoc Module/README Module/iwpriv_usage.txt
	# The firmware install
	insinto /etc/Wireless/RT73STA
	doins Module/rt73.bin Module/rt73sta.dat
}

pkg_postinst() {
	linux-mod_pkg_postinst

	einfo
	einfo "Thanks to RaLink for releasing open drivers!"
	einfo
}
