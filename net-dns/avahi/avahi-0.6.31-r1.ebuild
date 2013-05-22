# Copyright 1999-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

DESCRIPTION="System which facilitates service discovery on a local network (meta package)"
HOMEPAGE="http://avahi.org/"
SRC_URI=""

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="autoipd bookmarks dbus doc gdbm gtk gtk3 howl-compat +introspection ipv6
kernel_linux mdnsresponder-compat mono python qt4 test utils"

COMMON_DEPEND="=net-dns/avahi-base-${PVR}[autoipd=,bookmarks=,dbus=,doc=,gdbm=,howl-compat=,introspection=,ipv6=,mdnsresponder-compat=,python=,test=]
	gtk? ( =net-dns/avahi-gtk-${PVR} )
	utils? ( =net-dns/avahi-gtk-${PVR}[utils] )
	gtk3? ( =net-dns/avahi-gtk3-${PVR} )
	mono? ( =net-dns/avahi-mono-${PVR} )
	qt4? ( =net-dns/avahi-qt-${PVR} )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${DEPEND}"
