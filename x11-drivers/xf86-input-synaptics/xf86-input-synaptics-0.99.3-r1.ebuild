# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-synaptics/xf86-input-synaptics-0.99.3.ebuild,v 1.1 2008/12/18 13:50:38 chainsaw Exp $

inherit toolchain-funcs eutils linux-info x-modular

DESCRIPTION="Driver for Synaptics touchpads"
HOMEPAGE="http://cgit.freedesktop.org/xorg/driver/xf86-input-synaptics/"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
LICENSE="MIT"
IUSE=""
RDEPEND="x11-libs/libXext
	 hal? ( sys-apps/hal )"
DEPEND="${RDEPEND}
	!x11-drivers/synaptics
	x11-base/xorg-server
	x11-proto/inputproto
	>=sys-apps/sed-4"

evdev-input_check() {
	# Check kernel config for required event interface support (either
	# built-in or as a module. Bug #134309.

	ebegin "Checking kernel config for event device support"
	linux_chkconfig_present INPUT_EVDEV
	eend $?

	if [[ $? -ne 0 ]] ; then
		ewarn "Synaptics driver requires event interface support."
		ewarn "Please enable the event interface in your kernel config."
		ewarn "The option can be found at:"
		ewarn
		ewarn "  Device Drivers"
		ewarn "    Input device support"
		ewarn "      -*- Generic input layer"
		ewarn "        <*> Event interface"
		ewarn
		ewarn "Then rebuild the kernel or install the module."
		epause 5
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	evdev-input_check
}

src_unpack() {
	x-modular_unpack_source
	epatch "${FILESDIR}/0.99.2-fdi-comments.patch"
	epatch "${FILESDIR}/${P}-xorg-settings.patch"
}

src_install() {
	DOCS="INSTALL NEWS TODO README"
	x-modular_src_install

	# Stupid new daemon, didn't work for me because of shm issues
	newinitd "${FILESDIR}"/rc.init syndaemon
	newconfd "${FILESDIR}"/rc.conf syndaemon

	# Have HAL assign this driver to supported touchpads.
	insinto /usr/share/hal/fdi/policy/10osvendor
	doins "${S}"/fdi/11-x11-synaptics.fdi
}

pkg_postinst() {
	einfo "Synaptics settings are now stored in: "
	einfo "/usr/share/hal/fdi/policy/10osvendor/11-x11-synaptics.fdi"
	ewarn "You need to migrate your settings and clear them from xorg.conf"
}
