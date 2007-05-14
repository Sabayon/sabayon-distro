# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils

DESCRIPTION="Network configuration and management in an easy way. Desktop env independent"
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
SRC_URI="mirror://gentoo/NetworkManager-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="crypt doc"

RDEPEND=">=sys-apps/dbus-0.60
	>=sys-apps/hal-0.5
	sys-apps/iproute2
	>=dev-libs/libnl-1.0_pre6
	net-misc/dhcdbd
	>=net-wireless/wireless-tools-28_pre9
	>=net-wireless/wpa_supplicant-0.5.7
	>=dev-libs/glib-2.8
	crypt? ( dev-libs/libgcrypt )
	"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

S=${WORKDIR}/NetworkManager-${PV}

DOCS="AUTHORS COPYING ChangeLog INSTALL NEWS README"
USE_DESTDIR="1"

src_unpack () {
	unpack ${A}
	cd ${S}

        epatch ${FILESDIR}/${PN}-updatedbackend.patch
        epatch ${FILESDIR}/${PN}-use-kernel-headers.patch
        epatch ${FILESDIR}/${PN}-resolvconf-perms.patch
        epatch ${FILESDIR}/${PN}-0.6.5-confchanges.patch
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
	epatch ${FILESDIR}/${PN}-0.6.5-better-suspend.patch

	# Better multiple ESSID support	
	epatch ${FILESDIR}/${PN}-0.6.5-better-multiple-essid-support.patch

	# Better timeout handling
	epatch ${FILESDIR}/${PN}-0.6.5-grow-reconnection-timeout.patch

}

src_compile() {
	ECONF_OPTS="${G2CONF} \
		`use_with crypt gcrypt` \
		--disable-more-warnings \
		--localstatedir=/var \
		--with-distro=gentoo \
		--with-dbus-sys=/etc/dbus-1/system.d"

	econf ${ECONF_OPTS} || die "configure failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"
	keepdir /var/run/NetworkManager
}

pkg_postinst() {
	einfo
	einfo "NetworkManager doesn't work with all wifi devices"
	einfo "to see if your card is supported please visit"
	einfo "http://live.gnome.org/NetworkManagerHardware"
	einfo
	einfo "You can use NetworkManager instead of baselayout"
	einfo "to manage your networks but you are advised to use"
	einfo "baselayout because NetworkManager is beta software"
	einfo "and don't work fully as expected."
	einfo
	einfo "If it's the first time you run NetworkManager please"
	einfo "restart dbus doing /etc/init.d/dbus restart"
	einfo
	einfo "To use NetworkManager disable all entries on runlevels"
	einfo "net.***X and run /etc/init.d/NetworkManager"
	einfo "you can add to runlevels writing on your terminal"
	einfo "rc-update add NetworkManager default"
	einfo
	ebeep
}
