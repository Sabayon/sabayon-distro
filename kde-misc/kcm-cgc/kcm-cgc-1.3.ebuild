# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

KDE_MINIMAL="4.5"
inherit kde4-base

DESCRIPTION="KCM for set the look&feel of your Gtk apps using the KDE systemsettings."
HOMEPAGE="http://kde-apps.org/content/show.php?content=137496"
SRC_URI="http://chakra-project.org/sources/gtk-integration/chakra-gtk-config-${PV}.tar.gz"

LICENSE="GPL-3"

KEYWORDS="~amd64 ~x86"
SLOT="4"
IUSE=""

COMMON_DEPEND="$(add_kdebase_dep kdelibs)"
DEPEND="${COMMON_DEPEND}
	dev-util/automoc
"
RDEPEND="${COMMON_DEPEND}
	$(add_kdebase_dep kcmshell)
"

S="${WORKDIR}/chakra-gtk-config-${PV}"

src_prepare() {
	if [[ $(kde4-config --version | grep KDE | cut -d "." -f 2) -lt 6 ]] ; then
		einfo "KDE version < 4.6. Altering desktop file..."
		sed -i \
			-e "s/Parent-Category[^ ]*/Parent-Category=appearance/" \
		chakra-gtk-config.desktop && einfo "completed." || ewarn "failed."
	fi
}
