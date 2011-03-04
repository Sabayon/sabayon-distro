# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Little CMS ICC profile construction set"
HOMEPAGE="http://lprof.sourceforge.net/"
SRC_URI="mirror://sourceforge/lprof/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-libs/qt-core:4[qt3support]
	x11-libs/qt-assistant:4
	dev-libs/openssl
	sys-libs/zlib
	media-libs/libpng
	media-libs/tiff
	virtual/jpeg
	media-libs/vigra
	virtual/libusb
	x11-libs/libX11
	"
RDEPEND="${DEPEND}"

DOCS="README"
