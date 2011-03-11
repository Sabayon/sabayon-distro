# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"

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
# Have to get kdepim l10n locales because they're missing in recent
# packages
KDEPIM_PV="4.5.0"
SRC_URI="${SRC_URI/-${MY_LANG}-${PV}.tar.bz2/}/${PN}-${PV}.tar.bz2
    mirror://sabayon/${CATEGORY}/kdepim-l10n/kdepim-4.4.5-l10n.tar.bz2"

kde-l10n_src_prepare() {
    # override kde4-base_src_prepare which
    # fails at enable_selected_doc_linguas
    base_src_prepare

    # kdepim locale support
    PIM_S="${WORKDIR}/${PN}-${KDEPIM_PV}"
    if [ -d "${PIM_S}" ]; then
        cp "${PIM_S}/docs/kdepim" "${S}"/docs/ -rp || die
        cp "${PIM_S}/messages/kdepim" "${S}"/messages/ -rp || die
        echo "add_subdirectory( kdepim )" >> "${S}"/docs/CMakeLists.txt
        echo "add_subdirectory( kdepim )" >> "${S}"/messages/CMakeLists.txt
    fi

}

kde-l10n_src_configure() {
    mycmakeargs="${mycmakeargs}
        $(cmake-utils_use_build handbook docs)"
    kde4-base_src_configure
}
