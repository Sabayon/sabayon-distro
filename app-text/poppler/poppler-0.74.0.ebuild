# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base (meta package)"
HOMEPAGE="https://poppler.freedesktop.org/"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm"
SLOT="0/85"
IUSE="cairo cjk curl cxx debug doc +introspection +jpeg +jpeg2k +lcms nss png qt5 tiff +utils"

DEPEND="
	~app-text/poppler-base-${PV}[cxx=]
	~app-text/poppler-base-${PV}[curl=]
	~app-text/poppler-base-${PV}[debug=]
	~app-text/poppler-base-${PV}[jpeg=]
	~app-text/poppler-base-${PV}[jpeg2k=]
	~app-text/poppler-base-${PV}[lcms=]
	~app-text/poppler-base-${PV}[png=]
	~app-text/poppler-base-${PV}[tiff=]
	~app-text/poppler-base-${PV}[utils=]
	~app-text/poppler-base-${PV}[nss=]
	"

RDEPEND="${DEPEND}"

PDEPEND="cairo? (
		~app-text/poppler-glib-${PV}[cairo,cjk=,curl=,cxx=,debug=,doc=,introspection=,jpeg=,jpeg2k=,lcms=,nss=,png=,tiff=,utils=]
	)
	qt5? ( ~app-text/poppler-qt5-${PV}[cjk=,curl=,cxx=,debug=,doc=,jpeg=,jpeg2k=,lcms=,nss=,png=,tiff=,utils=] )
	"
