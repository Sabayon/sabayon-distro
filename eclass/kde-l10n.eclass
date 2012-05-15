# Copyright 2004-2012 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

inherit base kde4-base

MY_LANG="${PN/kde-l10n-/}"

# export all the available functions here
EXPORT_FUNCTIONS src_prepare src_configure

L10N_NAME="${L10N_NAME:-${MY_LANG}}"
DESCRIPTION="KDE4 ${L10N_NAME} localization package"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"
DEPEND=">=sys-devel/gettext-0.15"
RDEPEND=""
IUSE="+handbook"

kde-l10n_src_prepare() {
    # override kde4-base_src_prepare which
    # fails at enable_selected_doc_linguas
    base_src_prepare
}

kde-l10n_src_configure() {
    mycmakeargs="${mycmakeargs}
        $(cmake-utils_use_build handbook docs)"
    kde4-base_src_configure
}
