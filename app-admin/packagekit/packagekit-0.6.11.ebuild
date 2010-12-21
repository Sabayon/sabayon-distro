# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="PackageKit Package Manager interface (meta package)"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="connman +consolekit cron doc gtk networkmanager nsplugin pm-utils
+policykit +portage entropy qt4 static-libs test udev"

DEPEND=""
RDEPEND="doc? ( ~app-admin/packagekit-base-${PV}[doc] )
	connman? ( ~app-admin/packagekit-base-${PV}[connman] )
	gtk? ( ~app-admin/packagekit-gtk-${PV} )
	networkmanager? ( ~app-admin/packagekit-base-${PV}[networkmanager] )
	nsplugin? ( ~app-admin/packagekit-base-${PV}[nsplugin] )
	policykit? ( ~app-admin/packagekit-base-${PV}[policykit] )
	qt4? ( ~app-admin/packagekit-qt4-${PV} )
	udev? ( ~app-admin/packagekit-base-${PV}[udev] )
	entropy? ( ~app-admin/packagekit-base-${PV}[entropy] )
	consolekit? ( ~app-admin/packagekit-base-${PV}[consolekit] )
	pm-utils? ( ~app-admin/packagekit-base-${PV}[pm-utils] )"

