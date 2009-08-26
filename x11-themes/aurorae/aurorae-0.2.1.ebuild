# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit kde4-base

DESCRIPTION="Aurorae Theme Engine for kde-4"
HOMEPAGE="http://www.kde-look.org/content/show.php/Aurorae+Theme+Engine?content=107158"
SRC_URI="http://www.kde-look.org/CONTENT/content-files/107158-${P}.tar.gz"

SLOT="4"
LICENSE="GPL"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}"

DEPEND=">=kde-base/kwin-4.3.0"
RDEPEND="${DEPEND}"

src_prepare() {
	kde4-base_src_prepare

	# Prevent a gentoo-specific linking error.
	sed -e 's/${KDE4WORKSPACE_KDECORATIONS_LIBS}/kdecorations/g' \
		-i "${S}"/src/CMakeLists.txt || die "Patching failed!"
}

src_install() {
	kde4-base_src_install
	dodoc theme-description || die "dodoc failed"
}

