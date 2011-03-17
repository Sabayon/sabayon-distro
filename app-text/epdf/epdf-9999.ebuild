# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_SUB_PROJECT="PROTO"
inherit enlightenment

DESCRIPTION="PDF viewer with widgets for Evas"
KEYWORDS="~amd64 ~x86"
IUSE="cjk poppler static-libs"

LICENSE="GPL-2 || ( LGPL-3 )"

DEPEND="poppler? ( >=app-text/poppler-0.12 )
	>=media-libs/evas-9999
	>=dev-libs/ecore-9999"
RDEPEND="${DEPEND}"

src_configure() {
	MY_ECONF="
		$(use_enable poppler)
		$(use_enable !poppler mupdf)
		"
	use poppler || MY_ECONF+=" $(use_enable cjk mupdf-cjk)"

	enlightenment_src_configure
}
