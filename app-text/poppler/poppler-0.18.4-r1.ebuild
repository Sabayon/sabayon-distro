# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base (meta package)"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="cairo cjk +cxx debug doc +introspection jpeg jpeg2k +lcms png qt4 tiff +utils +xpdf-headers"

COMMON_DEPEND="~app-text/poppler-base-${PV}[cxx=]
	jpeg? ( ~app-text/poppler-base-${PV}[jpeg] )
	jpeg2k? ( ~app-text/poppler-base-${PV}[jpeg2k] )
	lcms? ( ~app-text/poppler-base-${PV}[lcms] )
	png? ( ~app-text/poppler-base-${PV}[png] )
	tiff? ( ~app-text/poppler-base-${PV}[tiff] )"

DEPEND="${COMMON_DEPEND} virtual/pkgconfig"

PDEPEND="cairo? ( ~app-text/poppler-glib-${PV}[cairo,introspection=] ) qt4? ( ~app-text/poppler-qt4-${PV} )"

RDEPEND="${COMMON_DEPEND} cjk? ( >=app-text/poppler-data-0.2.1 )"
