# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit cmake-utils

DESCRIPTION="A virtual lighttable and darkroom for photographers"
HOMEPAGE="http://darktable.sourceforge.net/index.shtml"
SRC_URI="http://downloads.sourceforge.net/project/darktable/darktable/0.8/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+lensfun openmp gnome-keyring static-libs nls watermark doc"

RDEPEND="dev-db/sqlite:3
	doc? ( dev-java/fop )
	dev-libs/dbus-glib
	gnome-base/gconf
	gnome-keyring? ( gnome-base/gnome-keyring )
	media-gfx/exiv2
	virtual/jpeg
	>=media-libs/libgphoto2-2.4.5
	media-libs/lcms
	lensfun? ( >=media-libs/lensfun-0.2.3 )
	media-libs/libpng
	media-libs/openexr
	media-libs/tiff
	net-misc/curl
	x11-libs/cairo
	x11-libs/gtk+:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	openmp? ( >=sys-devel/gcc-4.4[openmp] )"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_configure() {
	mycmakeargs=(
		$( cmake-utils_use_enable static-libs static )
		$( cmake-utils_use_enable gnome-keyring gkeyring )
		$( cmake-utils_use_enable openmp )
		$( cmake-utils_use_enable lensfun )
		$( cmake-utils_use_enable nls )
		$( cmake-utils_use_enable watermark )
		$( cmake-utils_use_enable doc docs )
		-DDONT_INSTALL_GCONF_SCHEMAS=ON
	)

	cmake-utils_src_configure
}
