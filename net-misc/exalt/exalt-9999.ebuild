# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

SVN_SUBDIR="/PROTO"
E17_EXTRA_CONF="--with-wpa-supplicant=/sbin/wpa_supplicant"
inherit enlightenment

DESCRIPTION="The enlightenment network manager"
HOMEPAGE="http://www.enlightenment.org/"

KEYWORDS="~amd64 ~x86"
IUSE="dhcp"

RDEPEND="net-wireless/wpa_supplicant
		 dhcp? ( net-misc/dhcp )
		 >=dev-libs/ecore-0.9.9.037
		 >=dev-libs/eet-0.9.9.038
		 >=dev-libs/e_dbus-0.1.0.002[hal]
		 >=media-libs/evas-0.9
		 >=x11-libs/elementary-0.1"

DEPEND="${DEPEND}"
