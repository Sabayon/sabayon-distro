# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=2

inherit eutils gnome2

DESCRIPTION="Utility to organize and develop raw images"
HOMEPAGE="http://darktable.sf.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="openmp"
DEPEND=">=x11-libs/gtk+-2.18.0
	>=gnome-base/libglade-2.6.3
	>=dev-db/sqlite-3.6.11
	>=x11-libs/cairo-1.8.6
	>=media-libs/gegl-0.0.22
	>=media-libs/lcms-1.17
	>=media-libs/jpeg-6b-r8
	>=media-gfx/exiv2-0.18.1
	>=media-libs/libpng-1.2.38
	>=dev-util/intltool-0.40.5
	>=media-libs/lensfun-0.2.4
	>=gnome-base/gconf-2.24.0
	>=media-libs/tiff-3.9.2"
RDEPEND="${DEPEND}"

src_prepare() {
	# Delete gexttext_domain entries (as used by Ubuntu)
	# to shrink gconf entries until supported by upstream Gnome.
	# https://bugzilla.gnome.org/show_bug.cgi?id=568845
	sed -i '/gettext_domain/d' darktable.schemas.in

	gnome2_src_prepare
}

src_configure() {
	econf $(use_enable openmp)
}
