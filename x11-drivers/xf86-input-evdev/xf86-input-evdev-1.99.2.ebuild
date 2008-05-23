# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-evdev/xf86-input-evdev-1.2.0.ebuild,v 1.8 2008/04/09 17:19:05 armin76 Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"
XDPVER=4

inherit x-modular

DESCRIPTION="Generic Linux input driver"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~sparc ~x86"

RDEPEND=">=x11-base/xorg-server-1.4.0.90
	>=sys-apps/hal-0.5.10"
DEPEND="${RDEPEND}
	|| ( >=sys-kernel/linux-headers-2.6 >=sys-kernel/mips-headers-2.6 )
	>=x11-proto/inputproto-1.4
	x11-proto/randrproto
	x11-proto/xproto"

pkg_postinst() {
	elog "If your XKB (keyboard settings) stopped working,"
	elog "you may uninstall this driver or move your XKB configuration."
	elog "Download an example from http://dev.gentoo.org/~compnerd/temp/hal-config-examples/"
	elog "(these will be installed with sys-apps/hal soon),"
	elog "and drop it into /etc/hal/fdi/policy/"
}
