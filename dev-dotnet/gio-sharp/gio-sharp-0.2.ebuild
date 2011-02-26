# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit autotools

DESCRIPTION="Bindings to Glib's libgio"
HOMEPAGE="http://github.com/mono/gio-sharp"
SRC_URI="https://github.com/mono/gio-sharp/tarball/master -> mono-gio-sharp-0.2.tar.gz"
MY_PN="mono-gio-sharp-017c8a5"
S="${WORKDIR}/${MY_PN}"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

GLIB_REQUIRED=2.22
GIO_SHARP_VERSION=2.22.2

DEPEND=">=dev-dotnet/glib-sharp-2.12
    >=dev-dotnet/gtk-sharp-gapi-2.12
	>=dev-libs/glib-${GLIB_REQUIRED}"
RDEPEND="${DEPEND}"

src_prepare() {
	CSC_FLAGS="-d:GIO_SHARP_2_22"
	sed -e "s/@GIO_SHARP_VERSION@/$GIO_SHARP_VERSION/"  \
	    -e "s/@GLIB_REQUIRED@/$GLIB_REQUIRED/"          \
	    -e "s/@CSC_FLAGS@/$CSC_FLAGS/"                  \
	    configure.ac.in > configure.ac
	ln -f sources/sources-$GLIB_REQUIRED.xml sources/sources.xml
	ln -f gio/gio-api-$GLIB_REQUIRED.raw gio/gio-api.raw
	eautoreconf
}

src_configure() {
	econf
}

src_compile() {
	emake -j1
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
