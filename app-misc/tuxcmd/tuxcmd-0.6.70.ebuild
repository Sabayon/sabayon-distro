# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils gnome2

DESCRIPTION="Tux Commander - Fast and Small filemanager using GTK2"
HOMEPAGE="http://tuxcmd.sourceforge.net/"
SRC_URI="mirror://sourceforge/tuxcmd/tuxcmd-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64" # FreePascal restrictions
IUSE=""

QA_PRESTRIPPED="/usr/bin/tuxcmd"

RDEPEND=">=x11-libs/gtk+-2.4.0:2
	>=dev-libs/glib-2.16.0
	>=x11-libs/pango-1.4.0
	x11-libs/cairo
	dev-libs/expat
	>=media-libs/libpng-1.4
	dev-libs/atk"

DEPEND="${RDEPEND}
	>=dev-lang/fpc-2.2.4"

pkg_preinst() {
	gnome2_icon_savelist
}

src_configure() {
	einfo "Nothing to configure."
}

src_install() {
	emake DESTDIR="${ED}/usr" install || die "emake install failed" # yep ${ED}
	rm -f "${ED}"/usr/share/doc/tuxcmd/COPYING
	gnome2_icon_cache_update
}

pkg_postinst() {
	gnome2_icon_cache_update
	einfo ""
	elog "Modules for Tux Commander are available in"
	elog "${CATEGORY}/tuxcmd-modules"
	einfo ""
}

pkg_postrm() {
	gnome2_icon_cache_update
}
