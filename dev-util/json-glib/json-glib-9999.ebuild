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

IUSE=""

DEPEND=">=dev-libs/glib-2.15
	>=dev-util/gtk-doc-1.11"
RDEPEND="${DEPEND}"

src_prepare() {

	# fix issue in buildsystem, atm we have to
	# force gtk-doc
	gtkdocize || die "failed to run gtkdocize"	

	eautoreconf
	elibtoolize
	eautoconf
	eautomake
}

src_configure() {
	econf --enable-gtk-doc || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
