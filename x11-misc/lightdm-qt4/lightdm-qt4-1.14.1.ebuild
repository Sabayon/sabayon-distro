# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit autotools eutils versionator

TRUNK_VERSION="$(get_version_component_range 1-2)"
REAL_PN="${PN/-qt4}"
REAL_P="${P/-qt4}"
DESCRIPTION="Qt4 libraries for LightDM"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/LightDM"
SRC_URI="http://launchpad.net/${REAL_PN}/${TRUNK_VERSION}/${PV}/+download/${REAL_P}.tar.xz
	mirror://gentoo/introspection-20110205.m4.tar.bz2"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

COMMON_DEPEND="~x11-misc/lightdm-base-${PV}"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

DOCS=( NEWS )
S="${WORKDIR}/${REAL_P}"

src_prepare() {
	epatch_user

	# Remove bogus Makefile statement. This needs to go upstream
	sed -i /"@YELP_HELP_RULES@"/d help/Makefile.am || die
	if has_version dev-libs/gobject-introspection; then
		eautoreconf
	else
		AT_M4DIR=${WORKDIR} eautoreconf
	fi
}

src_configure() {
	econf \
		--localstatedir=/var \
		--disable-static \
		--disable-tests \
		--disable-introspection \
		--enable-liblightdm-qt \
		--disable-liblightdm-qt5
}

src_compile() {
	cd "${S}/liblightdm-qt" && \
		emake
}

src_install() {
	cd "${S}/liblightdm-qt" && \
		emake DESTDIR="${ED}" install
}
