# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
inherit kde4-base

DESCRIPTION="KDE internationalization meta-package - merge this to pull in all kde-l10n packages"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS=""
IUSE=""
SRC_URI=""

DEPEND=""
LANGS="ar be bg ca csb de el en_GB eo es et eu fi fr ga gl hi hu it ja km ko lv
mk nb nds ne nl nn pa pl pt pt_BR ru se sl sv th tr uk wa zh_CN zh_TW"
RDEPEND="!kde-base/kde-l10n"
for X in ${LANGS} ; do
        IUSE="${IUSE} linguas_${X}"
        RDEPEND="${RDEPEND} linguas_${X}? ( ~kde-base/kde-l10n-${X}-${PV} )"
done

src_unpack() {
	einfo "nothing to unpack"
}


src_compile() {
	einfo "nothing to compile"
}

src_install() {
	einfo "nothing to install"
}
