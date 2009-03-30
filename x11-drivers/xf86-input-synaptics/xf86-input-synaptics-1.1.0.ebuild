# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-synaptics/xf86-input-synaptics-1.0.0.ebuild,v 1.2 2009/03/20 14:47:19 chainsaw Exp $

inherit toolchain-funcs eutils x-modular

DESCRIPTION="Driver for Synaptics touchpads"
HOMEPAGE="http://cgit.freedesktop.org/xorg/driver/xf86-input-synaptics/"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
LICENSE="MIT"
IUSE="hal"
RDEPEND="x11-libs/libXext
	 hal? ( sys-apps/hal )"
DEPEND="${RDEPEND}
	!x11-drivers/synaptics
	x11-base/xorg-server
	x11-proto/inputproto
	>=sys-apps/sed-4"

src_unpack() {
	x-modular_src_unpack
	epatch "${FILESDIR}/${PN}-1.0.0-xorg-settings.patch"
	epatch "${FILESDIR}/${P}-dont-fail-with-x1.5.patch"
}

src_install() {
	DOCS="INSTALL NEWS TODO README"
	x-modular_src_install

	# Stupid new daemon, didn't work for me because of shm issues
	newinitd "${FILESDIR}"/rc.init syndaemon
	newconfd "${FILESDIR}"/rc.conf syndaemon

	if use hal ; then
		insinto /usr/share/hal/fdi/policy/10osvendor
		doins "${S}"/fdi/11-x11-synaptics.fdi
		dodir /etc/hal/fdi/policy
		insinto /etc/hal/fdi/policy
		doins "${S}"/fdi/11-x11-synaptics.fdi
	fi
}

pkg_postinst() {
	elog "This driver requires event interface support in your kernel: INPUT_EVDEV"
	if use hal ; then
		elog "Synaptics settings are now stored in:"
		elog "/etc/hal/fdi/policy/10osvendor/11-x11-synaptics.fdi"
		echo
		ewarn "Please see the examples here for inspiration, but not edit:"
		ewarn "/usr/share/hal/fdi/policy/10osvendor/11-x11-synaptics.fdi"
	fi
}
