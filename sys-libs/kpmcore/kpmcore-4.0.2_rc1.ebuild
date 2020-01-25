# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

KFMIN=5.60.0
QTMIN=5.12.3
_KDE_ORG_ECLASS=1
KDE_BUILD_TYPE="live"
inherit ecm git-r3 kde.org

EGIT_REPO_URI="https://github.com/KDE/kpmcore.git"
EGIT_COMMIT="d24191ebd8ee4a1792003e5bd280cb7679f5e834"

DESCRIPTION="Library for managing partitions"
HOMEPAGE="https://kde.org/applications/system/org.kde.partitionmanager"

LICENSE="GPL-3"
SLOT="5/8"
IUSE=""
KEYWORDS="amd64 ~arm ~arm64 x86"

BDEPEND="virtual/pkgconfig"
DEPEND="
	|| (
		app-crypt/qca[botan]
		app-crypt/qca[ssl]
	)
	>=dev-qt/qtdbus-${QTMIN}:5
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtwidgets-${QTMIN}:5
	>=kde-frameworks/kauth-${KFMIN}:5
	>=kde-frameworks/kcoreaddons-${KFMIN}:5
	>=kde-frameworks/ki18n-${KFMIN}:5
	>=kde-frameworks/kwidgetsaddons-${KFMIN}:5
	>=sys-apps/util-linux-2.33.2
"
RDEPEND="${DEPEND}"

# bug 689468, tests need polkit etc.
RESTRICT+=" test"
