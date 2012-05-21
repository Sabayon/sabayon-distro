# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.9.4.0-r2.ebuild,v 1.1 2012/04/13 21:18:23 tetromino Exp $

EAPI="4"
GNOME_ORG_MODULE="NetworkManager"

inherit autotools eutils gnome.org linux-info systemd

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"

LICENSE="GPL-2"
SLOT="0"
IUSE="avahi bluetooth connection-sharing dhclient +dhcpcd doc gnutls +introspection kernel_linux +nss modemmanager +ppp resolvconf systemd wext wimax"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"

REQUIRED_USE="
	modemmanager? ( ppp )
	^^ ( nss gnutls )
	^^ ( dhclient dhcpcd )"

# gobject-introspection-0.10.3 is needed due to gnome bug 642300
# wpa_supplicant-0.7.3-r3 is needed due to bug 359271
# libnl:1.1 is needed for linking to net-wireless/wimax libraries
# XXX: on bump, check that net-wireless/wimax is still using libnl:1.1 !
# TODO: Qt support?
COMMON_DEPEND=">=sys-apps/dbus-1.2
	>=dev-libs/dbus-glib-0.75
	|| ( >=sys-fs/udev-171[gudev] >=sys-fs/udev-147[extras] )
	>=dev-libs/glib-2.26
	>=sys-auth/polkit-0.97
	>=net-libs/libsoup-2.26:2.4
	>=net-wireless/wpa_supplicant-0.7.3-r3[dbus]
	bluetooth? ( >=net-wireless/bluez-4.82 )
	avahi? ( net-dns/avahi[autoipd] )
	gnutls? (
		dev-libs/libgcrypt
		net-libs/gnutls )
	nss? ( >=dev-libs/nss-3.11 )
	dhclient? ( net-misc/dhcp )
	dhcpcd? ( >=net-misc/dhcpcd-4.0.0_rc3 )
	introspection? ( >=dev-libs/gobject-introspection-0.10.3 )
	ppp? ( >=net-dialup/ppp-2.4.5 )
	resolvconf? ( net-dns/openresolv )
	connection-sharing? (
		net-dns/dnsmasq
		net-firewall/iptables )
	wimax? (
		dev-libs/libnl:1.1
		>=net-wireless/wimax-1.5.1 )
	!wimax? ( dev-libs/libnl:3 )"

RDEPEND="${COMMON_DEPEND}
	modemmanager? ( >=net-misc/modemmanager-0.4 )
	systemd? ( >=sys-apps/systemd-31 )
	!systemd? ( sys-auth/consolekit )
	virtual/logger"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	>=sys-kernel/linux-headers-2.6.29
	doc? ( >=dev-util/gtk-doc-1.8 )"

sysfs_deprecated_check() {
	ebegin "Checking for SYSFS_DEPRECATED support"

	if { linux_chkconfig_present SYSFS_DEPRECATED_V2; }; then
		eerror "Please disable SYSFS_DEPRECATED_V2 support in your kernel config and recompile your kernel"
		eerror "or NetworkManager will not work correctly."
		eerror "See http://bugs.gentoo.org/333639 for more info."
		die "CONFIG_SYSFS_DEPRECATED_V2 support detected!"
	fi
	eend $?
}

pkg_pretend() {
	if use kernel_linux; then
		get_version
		if linux_config_exists; then
			sysfs_deprecated_check
		else
			ewarn "Was unable to determine your kernel .config"
			ewarn "Please note that if CONFIG_SYSFS_DEPRECATED_V2 is set in your kernel .config, NetworkManager will not work correctly."
			ewarn "See http://bugs.gentoo.org/333639 for more info."
		fi

	fi
}

pkg_setup() {
	enewgroup plugdev
}

src_prepare() {
	# Don't build tests
	epatch "${FILESDIR}/${PN}-0.9_rc3-fix-tests.patch"
	# Build against libnl:1.1 for net-wireless/wimax-1.5.2 compatibility
	epatch "${FILESDIR}/${PN}-0.9.4.0-force-libnl1.1-r1.patch"
	# Update init.d script to provide net and use inactive status if not connected
	epatch "${FILESDIR}/${PN}-0.9.2.0-init-provide-net-r1.patch"
	# Bug #402085, https://bugzilla.gnome.org/show_bug.cgi?id=387832
	epatch "${FILESDIR}/${PN}-0.9.2.0-pre-sleep.patch"
	# Fix quote handling for global data (Bug #410821)
	epatch "${FILESDIR}/${PN}-0.9.4.0-fix-quote-handling.patch"
	# Fix uninitialized variables in libnm-glib
	epatch "${FILESDIR}/${P}-libnm-glib-ensure_inited.patch"
	epatch "${FILESDIR}/${P}-libnm-glib-init-gerror.patch"

	# Sabayon patch, require logger, avoid modemmanager or other plugins
	# output on VT
	epatch "${FILESDIR}/${PN}-init-need-logger-2.patch"

	eautoreconf
	default
}

src_configure() {
	ECONF="--disable-more-warnings
		--disable-static
		--localstatedir=/var
		--with-distro=gentoo
		--with-dbus-sys-dir=/etc/dbus-1/system.d
		--with-udev-dir=/lib/udev
		--with-iptables=/sbin/iptables
		--enable-concheck
		$(use_enable doc gtk-doc)
		$(use_enable introspection)
		$(use_enable ppp)
		$(use_enable wimax)
		$(use_with dhclient)
		$(use_with dhcpcd)
		$(use_with doc docs)
		$(use_with resolvconf)
		$(use_with wext)
		$(use_with wimax libnl-1)
		$(systemd_with_unitdir)"

		if use nss ; then
			ECONF="${ECONF} $(use_with nss crypto=nss)"
		else
			ECONF="${ECONF} $(use_with gnutls crypto=gnutls)"
		fi

		if use systemd; then
			ECONF="${ECONF} --with-session-tracking=systemd"
		else
			ECONF="${ECONF} --with-session-tracking=ck"
		fi

	econf ${ECONF}
}

src_install() {
	default
	# /var/run/NetworkManager is used by some distros, but not by Gentoo
	rmdir -v "${ED}/var/run/NetworkManager" || die "rmdir failed"

	# Sabayon Live boot support, make possible to turn off networkmanager
	# See bug 2400
	doinitd "${FILESDIR}/NetworkManager-setup"

	# Need to keep the /etc/NetworkManager/dispatched.d for dispatcher scripts
	dodir /etc/NetworkManager/dispatcher.d
	keepdir /etc/NetworkManager/dispatcher.d

	# Provide openrc net dependency only when nm is connected
	exeinto /etc/NetworkManager/dispatcher.d
	newexe "${FILESDIR}/10-openrc-status-r1" 10-openrc-status
	sed -e "s:@EPREFIX@:${EPREFIX}:g" \
		-i "${ED}/etc/NetworkManager/dispatcher.d/10-openrc-status" || die

	# Install script in /etc/NetworkManager/dispatcher.d to make netmount
	# users (and init service) a bit more happy when NM is in use.
	# In this way, at least network mounts are magically mounted
	doexe "${FILESDIR}"/01-netmount-up-down.rc
	fperms 0744 /etc/NetworkManager/dispatcher.d/01-netmount-up-down.rc

	# Add keyfile plugin support
	keepdir /etc/NetworkManager/system-connections
	chmod 0600 "${ED}"/etc/NetworkManager/system-connections/.keep* # bug #383765
	insinto /etc/NetworkManager
	newins "${FILESDIR}/nm-system-settings.conf-ifnet" NetworkManager.conf

	# Allow users in plugdev group to modify system connections
	insinto /etc/polkit-1/localauthority/10-vendor.d
	doins "${FILESDIR}/01-org.freedesktop.NetworkManager.settings.modify.system.pkla"

	# Default conf.d file
	newconfd "${FILESDIR}/conf.d.NetworkManager" NetworkManager

	# Remove useless .la files
	find "${D}" -name '*.la' -exec rm -f {} + || die "la file removal failed"
}

pkg_postinst() {
	elog "To modify system network connections without needing to enter the"
	elog "root password, add your user account to the 'plugdev' group."

	if [[ -e "${EROOT}etc/NetworkManager/nm-system-settings.conf" ]]; then
		ewarn "The ${PN} system configuration file has moved to a new location."
		ewarn "You must migrate your settings from ${EROOT}/etc/NetworkManager/nm-system-settings.conf"
		ewarn "to ${EROOT}etc/NetworkManager/NetworkManager.conf"
		ewarn
		ewarn "After doing so, you can remove ${EROOT}etc/NetworkManager/nm-system-settings.conf"
	fi
}
