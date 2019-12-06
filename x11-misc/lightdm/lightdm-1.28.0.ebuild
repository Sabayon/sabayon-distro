# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="LightDM meta package"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/LightDM"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="audit +gnome +gtk +introspection qt5 vala"

DEPEND="~x11-misc/lightdm-base-${PV}[introspection=]
	qt5? ( ~x11-misc/lightdm-qt5-${PV} )"
RDEPEND="${DEPEND}"
PDEPEND="
	gtk? ( x11-misc/lightdm-gtk-greeter )
"
