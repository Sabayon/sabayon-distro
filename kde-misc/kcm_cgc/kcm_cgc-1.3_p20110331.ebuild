# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

EGIT_REPO_URI="git://gitorious.org/chakra/chakra-gtk-config.git"
EGIT_COMMIT="09d0994"
inherit kde4-base git

DESCRIPTION="KCM for set the look&feel of your Gtk apps using the KDE systemsettings."
HOMEPAGE="http://kde-apps.org/content/show.php/Chakra+Gtk+Config+-+KCM?content=137496"
LICENSE="GPL-3"

KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

COMMON_DEPEND="kde-base/kdelibs"
DEPEND="${COMMON_DEPEND}
	dev-util/automoc"
RDEPEND="${COMMON_DEPEND}
	kde-base/kcmshell"

S="${WORKDIR}/chakra-gtk-config-${PV}"

src_prepare() {
	if [[ $(kde4-config --version | grep KDE | cut -d "." -f 2) -lt 6 ]] ; then
		einfo "KDE version < 4.6. Altering desktop file..."
		sed -i \
			-e "s/Parent-Category[^ ]*/Parent-Category=appearance/" \
		chakra-gtk-config.desktop && einfo "completed." || ewarn "failed."
	fi
}
