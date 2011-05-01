# Copyright 1999-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit kde4-base

DESCRIPTION="KCModule for configuring the GRUB2 bootloader."
HOMEPAGE="http://kde-apps.org/content/show.php?content=139643"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"

LICENSE="GPL-3"

KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="+imagemagick +hwinfo"

COMMON_DEPEND="
	>=kde-base/kdelibs-4.6
	imagemagick? ( media-gfx/imagemagick )
	hwinfo? ( sys-apps/hwinfo )"
DEPEND="${COMMON_DEPEND}
	dev-util/automoc"
RDEPEND="${COMMON_DEPEND}
	kde-base/kcmshell"

src_configure() {
	mycmakeargs=(
	$( cmake-utils_use_with imagemagick ImageMagick )
	$( cmake-utils_use_with hwinfo HD )
	)
	cmake-utils_src_configure
}
