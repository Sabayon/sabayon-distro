# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.6.5_p20070823.ebuild,v 1.4 2007/09/08 15:49:49 josejx Exp $

inherit gnome2 eutils

# NetworkManager likes itself with capital letters
MY_P=${P/networkmanager/NetworkManager}

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
#http://ftp.gnome.org/pub/gnome/sources/NetworkManager/0.6/
SRC_URI="mirror://gentoo/${MY_P}.tar.gz
	mirror://gentoo/${P}-updatedbackend.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ~x86"
IUSE="crypt doc gnome applet"

RDEPEND=">=sys-apps/dbus-0.60
	>=sys-apps/hal-0.5
	sys-apps/iproute2
	>=dev-libs/libnl-1.0_pre6
	>=net-misc/dhcdbd-1.4
	>=net-wireless/wireless-tools-28_pre9
	>=net-wireless/wpa_supplicant-0.5.7
	>=dev-libs/glib-2.8
	>=x11-libs/libnotify-0.3.2
	gnome? ( >=x11-libs/gtk+-2.8
		>=gnome-base/libglade-2
		>=gnome-base/gnome-keyring-0.4
		>=gnome-base/gnome-panel-2
		>=gnome-base/gconf-2
		>=gnome-base/libgnomeui-2 )
	crypt? ( dev-libs/libgcrypt )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"
PDEPEND="applet? ( >=gnome-extra/nm-applet-0.6.5 )"

DOCS="AUTHORS ChangeLog NEWS README"
USE_DESTDIR="1"

G2CONF="${G2CONF} \
	`use_with crypt gcrypt` \
	`use_with gnome` \
	--disable-more-warnings \
	--localstatedir=/var \
	--with-distro=gentoo \
	--with-dbus-sys=/etc/dbus-1/system.d \
	--enable-notification-icon"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if built_with_use sys-apps/iproute2 minimal ; then
		eerror "Please rebuild sys-apps/iproute2 without the minimal useflag."
		die "Fix iproute2 first."
	fi
}

src_unpack () {
	unpack ${A}
	cd "${S}"

	# Update to use our backend
	epatch "${WORKDIR}/${P}-updatedbackend.patch"
	# Use the kernel headers
	epatch "${FILESDIR}/${PN}-use-kernel-headers.patch"
	# Fix the resolv.conf permissions
	epatch "${FILESDIR}/${PN}-resolvconf-perms.patch"
	# Fix up the dbus conf file to use plugdev group
	epatch "${FILESDIR}/${PN}-0.6.5-confchanges.patch"

	epatch ${FILESDIR}/${PN}-0.6.4-dhcp-manager.c.patch
	
	# Fix possible early-xdm related problem
	# epatch ${FILESDIR}/${PN}-0.6.4-force-before-xdm.patch

	# Fix possible associations problems
	epatch ${FILESDIR}/${PN}-0.6.4-high-delay.patch

	# Add some workarounds for various drivers
	epatch ${FILESDIR}/${PN}-0.6.5-wireless-drivers-workarounds.patch

	# Fix net.lo restart
	epatch ${FILESDIR}/${PN}-0.6.4-Gentoo-checklo.patch

	# TESTING: try to change default madwifi driver
	epatch ${FILESDIR}/${PN}-0.6.4-substitute-madwifi-driver.patch

	# Remove buggy Gentoo set_hostname
	epatch ${FILESDIR}/${PN}-0.6.4-remove-gentoo-set-hostname.patch

	# Better suspend support, especially for ipw3945
	# epatch ${FILESDIR}/${PN}-0.6.5-better-suspend.patch

	# Better multiple ESSID support	
	epatch ${FILESDIR}/${PN}-0.6.5-better-multiple-essid-support.patch

	# Better timeout handling
	epatch ${FILESDIR}/${PN}-0.6.5-grow-reconnection-timeout.patch

	# Sometimes device gets downed during wpa_supplicant association
	epatch ${FILESDIR}/${PN}-0.6.5-stage3-device-always-up.patch

	# load before nfsmount
	epatch ${FILESDIR}/${PN}-0.6.5-load-before-nfsmount.patch

}

src_install() {
	gnome2_src_install
	# Need to keep the /var/run/NetworkManager directory
	keepdir /var/run/NetworkManager
}

pkg_postinst() {
	gnome2_icon_cache_update
	elog "You need to be in the plugdev group in order to use NetworkManager"
	elog "Problems with your hostname getting changed?"
	elog ""
	elog "Add the following to /etc/dhcp/dhclient.conf"
	elog 'send host-name "YOURHOSTNAME";'
	elog 'supersede host-name "YOURHOSTNAME";'

	elog "You will need to restart DBUS if this is your first time"
	elog "installing NetworkManager."
}
