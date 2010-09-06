# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit kde4-base

DESCRIPTION="KDE internationalization meta-package - merge this to pull in all kde-l10n packages"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI=""

RDEPEND="!kde-base/kde-l10n"
DEPEND=">=sys-devel/gettext-0.15"

DISABLED_LANGS="bn_IN csb se fa be mk ne hne tg is eo fy mr th"
LANGS="ar bg ca cs da de el en_GB es et eu fi fr ga gl gu he hi
	hu it ja kk km kn ko ku lt lv ml nb nds nl nn pa pl pt
	pt_BR ro ru sk sl sr sv tr uk wa zh_CN zh_TW"
for X in ${LANGS} ; do
        IUSE="${IUSE} linguas_${X}"
        RDEPEND="${RDEPEND} linguas_${X}? ( ~kde-base/kde-l10n-${X}-${PV} )"
done

src_prepare() {
	einfo "nothing to prepare"
}

src_configure() {
	einfo "nothing to configure"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	einfo "this is a meta-package, nothing to install"
}
