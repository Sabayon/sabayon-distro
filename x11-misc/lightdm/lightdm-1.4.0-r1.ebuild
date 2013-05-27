# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="LightDM meta package"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/LightDM"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE="+gtk +introspection kde qt4 razor"
REQUIRED_USE="|| ( gtk kde razor )"

COMMON_DEPEND="~x11-misc/lightdm-base-${PV}[introspection=]
	qt4? ( ~x11-misc/lightdm-qt4-${PV} )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}
	gtk? ( x11-misc/lightdm-gtk-greeter )
	kde? ( x11-misc/lightdm-kde )
	razor? ( razorqt-base/razorqt-lightdm-greeter )"
