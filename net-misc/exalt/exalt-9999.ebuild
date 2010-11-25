# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SVN_SUBDIR="/PROTO"
E17_EXTRA_CONF="--with-wpa-supplicant=/sbin/wpa_supplicant"
inherit enlightenment

DESCRIPTION="The enlightenment network manager"
HOMEPAGE="http://www.enlightenment.org/"

KEYWORDS="~amd64 ~x86"
IUSE="dhcp"

RDEPEND="net-wireless/wpa_supplicant
		 dhcp? ( net-misc/dhcp )
		 >=x11-libs/ecore-0.9.9.037
		 >=dev-libs/eet-0.9.9.038
		 >=x11-libs/e_dbus-0.1.0.002[hal]
		 >=x11-libs/evas-0.9
		 >=x11-libs/elementary-0.1"

DEPEND="${DEPEND}"
