# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

GNOME_ORG_MODULE="file-roller"
inherit eutils gnome.org

DESCRIPTION="Provides context menu for Nautilus"
HOMEPAGE="https://wiki.gnome.org/Apps/FileRoller"

LICENSE="GPL-2+"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~arm ~x86"

RDEPEND="
	~app-arch/file-roller-${PV}
	>=gnome-base/nautilus-3
"
DEPEND=">=gnome-base/nautilus-3
	>=dev-libs/glib-2.36:2
	sys-devel/gettext
	>=app-arch/libarchive-3:=
	>=dev-libs/json-glib-0.14
	dev-util/itstool
	virtual/pkgconfig
	>=x11-libs/gtk+-3.13.2:3
"

src_configure() {
	econf \
		--disable-run-in-place \
		--disable-static \
		--disable-debug \
		--enable-magic \
		--enable-libarchive \
		--enable-nautilus-actions \
		--disable-packagekit
}

src_compile() {
	cd nautilus || die
	emake
}

src_install() {
	cd nautilus || die
	emake DESTDIR="${D}" install
	find "${D}" -name '*.la' -exec rm -f {} + || die "la file removal failed"
}
