# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SLOT="${PV/.4}"
EAPI="2"

DESCRIPTION="KDE internationalization meta-package - merge this to pull in all kde-l10n packages"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI=""

DEPEND=">=sys-devel/gettext-0.15"
RDEPEND="!kde-base/kde-l10n"

DISABLED_LANGS="ar se fa eu be ne is eo fy"
LANGS="bg ca cs csb da de el en_GB es et fi fr ga gl hi hu
it ja kk km ko lv mk nb nds nl nn pa pl pt pt_BR ru sl sv th tr uk wa
zh_CN zh_TW"
for X in ${LANGS} ; do
        IUSE="${IUSE} linguas_${X}"
        RDEPEND="${RDEPEND} linguas_${X}? ( ~kde-base/kde-l10n-${X}-${PV} )"
done

