# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base (meta package)"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0/51"
IUSE="cairo cjk curl cxx debug doc +introspection +jpeg jpeg2k +lcms png qt4 qt5 tiff +utils"

COMMON_DEPEND="
	~app-text/poppler-base-${PV}[cxx=]
	~app-text/poppler-base-${PV}[curl=]
	~app-text/poppler-base-${PV}[debug=]
	~app-text/poppler-base-${PV}[jpeg=]
	~app-text/poppler-base-${PV}[jpeg2k=]
	~app-text/poppler-base-${PV}[lcms=]
	~app-text/poppler-base-${PV}[png=]
	~app-text/poppler-base-${PV}[tiff=]
	~app-text/poppler-base-${PV}[utils=]
	"

DEPEND="${COMMON_DEPEND} virtual/pkgconfig"

PDEPEND="cairo? (
		~app-text/poppler-glib-${PV}[cairo,introspection=,doc=]
	)
	qt4? ( ~app-text/poppler-qt4-${PV} )
	"
# add qt5 support when needed

RDEPEND="${COMMON_DEPEND} cjk? ( >=app-text/poppler-data-0.4.4 )"
