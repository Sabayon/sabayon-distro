# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI="2"

inherit enlightenment

DESCRIPTION="Enlightenment's (Ecore) integration to DBus"
SRC_URI="http://download.enlightenment.org/releases/${P}.tar.bz2"

KEYWORDS="~amd64 ~x86"
IUSE="bluetooth +connman +libnotify ofono static-libs test-binaries +udev"

RDEPEND=">=dev-libs/eina-1.0.0_beta
	>=dev-libs/ecore-1.0.0_beta
	sys-apps/dbus
	libnotify? ( >=media-libs/evas-1.0.0_beta )
	udev? ( sys-power/upower sys-fs/udisks )
"
DEPEND="${RDEPEND}"

src_configure() {
	MY_ECONF="
		$(use_enable bluetooth ebluez)
		$(use_enable connman econnman)
		$(use_enable doc)
		ehal
		$(use_enable libnotify enotify)
		$(use_enable ofono eofono)
		$(use_enable test-binaries edbus-test)
		$(use_enable test-binaries edbus-test-client)
		$(use_enable udev eukit)"
	if use test-binaries ; then
		MY_ECONF+="
			 $(use_enable bluetooth edbus-bluez-test)
			$(use_enable connman edbus-connman-test)
			$(use_enable libnotify edbus-notification-daemon-test)
			$(use_enable libnotify edbus-notify-test)
			$(use_enable ofono edbus-ofono-test)
			$(use_enable udev edbus-ukit-test)"
	else
		MY_ECONF+="
			 --disable-edbus-bluez-test
			--disable-edbus-connman-test
			--disable-edbus-notification-daemon-test
			--disable-edbus-notify-test
			--disable-edbus-ofono-test
			--disable-edbus-ukit-test"
	fi
	enlightenment_src_configure
}
