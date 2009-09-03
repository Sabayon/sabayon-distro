# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
EGIT_REPO_URI="git://git.gnome.org/json-glib"
inherit git autotools

DESCRIPTION="A library providing serialization and deserialization support for the JavaScript Object Notation (JSON) format."
HOMEPAGE="http://live.gnome.org/JsonGlib"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="doc"

DEPEND=">=dev-libs/glib-2.15
	doc? ( dev-util/gtk-doc )"
RDEPEND="${DEPEND}"

src_prepare() {

	# fix issue in buildsystem
	if use doc; then
		gtkdocize || die "failed to run gtkdocize"	
	else
		echo "EXTRA_DIST =" > "${S}/gtk-doc.make"
	fi

	eautoreconf
	elibtoolize
	eautoconf
	eautomake
}

src_configure() {
	econf $(use_enable doc gtk-doc) || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
