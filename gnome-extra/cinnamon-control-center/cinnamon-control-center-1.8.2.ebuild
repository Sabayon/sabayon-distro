# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit autotools eutils gnome2 multilib pax-utils

DESCRIPTION="Control center for cinnamon desktop"
HOMEPAGE="http://cinnamon.linuxmint.com/"

MY_PV="${PV/_p/-UP}"
MY_P="${PN}-${MY_PV}"

SRC_URI="https://github.com/linuxmint/cinnamon-control-center/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
IUSE="+bluetooth +colord +cups +i18n kerberos +networkmanager +socialweb systemd v4l"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	>=dev-libs/glib-2.31:2
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=x11-libs/gtk+-3.5.13:3
	>=gnome-base/gsettings-desktop-schemas-3.5.91
	>=gnome-base/gnome-desktop-3.5.91:3=
	>=gnome-base/gnome-settings-daemon-3.6[colord?,policykit]
	>=gnome-base/libgnomekbd-2.91.91

	app-text/iso-codes
	dev-libs/libpwquality
	dev-libs/libxml2:2
	gnome-base/gnome-menus:3
	gnome-base/libgtop:2
	media-libs/fontconfig

	>=media-libs/libcanberra-0.13[gtk3]
	>=media-sound/pulseaudio-2[glib]
	>=sys-auth/polkit-0.97
	>=sys-power/upower-0.9.1
	>=x11-libs/libnotify-0.7.3

	x11-apps/xmodmap
	x11-libs/libX11
	x11-libs/libXxf86misc
	>=x11-libs/libXi-1.2

	bluetooth? ( >=net-wireless/gnome-bluetooth-3.5.5:= )
	colord? ( >=x11-misc/colord-0.1.8 )
	cups? ( >=net-print/cups-1.4[dbus] )
	i18n? ( >=app-i18n/ibus-1.4.99 )
	networkmanager? (
		>=gnome-extra/nm-applet-0.9.1.90
		>=net-misc/networkmanager-0.8.997 )
	socialweb? ( net-libs/libsocialweb )"

DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
PDEPEND=">=gnome-extra/cinnamon-1.8.0"

#pkg_setup() {
#	python-single-r1_pkg_setup
#}

src_prepare() {
	epatch "${FILESDIR}/${PN}-optional-bt-colord.patch"
	epatch "${FILESDIR}/${PN}-optional-kerberos.patch"
	eautoreconf
	gnome2_src_prepare

}

src_configure() {
	G2CONF="${G2CONF}
		--disable-update-mimedb
		--disable-static
		--enable-documentation
		$(use_enable bluetooth)
		$(use_enable colord color)
		$(use_enable cups)
		$(use_enable i18n ibus)
		$(use_enable kerberos)
		$(use_with socialweb libsocialweb)
		$(use_enable systemd)
		$(use_with v4l cheese)"

	gnome2_src_configure
}

src_install() {
	gnome2_src_install
}

pkg_postinst() {
	gnome2_pkg_postinst

}
