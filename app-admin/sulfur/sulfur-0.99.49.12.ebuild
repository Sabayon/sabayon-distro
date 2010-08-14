# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils gnome2-utils fdo-mime python

DESCRIPTION="Official Sabayon Linux Package Manager Graphical Client (tagged release)"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="http://distfiles.sabayon.org/sys-apps/entropy-${PV}.tar.bz2"
RESTRICT="mirror"
S="${WORKDIR}/entropy-${PV}/sulfur"

RDEPEND="
	!app-admin/spritz
	>=dev-python/pygtk-2.12.1-r2
	>=x11-libs/vte-0.12.2[python]
	x11-misc/xdg-utils
	~sys-apps/entropy-${PV}
	sys-apps/file[python]"
DEPEND="sys-devel/gettext"

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" -j1 install || die "make install failed"
	dodir /etc/gconf/schemas
	insinto /etc/gconf/schemas
	doins "${S}/misc/entropy-handler.schemas"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	gnome2_gconf_savelist
	gnome2_gconf_install
	python_mod_optimize "/usr/$(get_libdir)/entropy/${PN}"
}

pkg_postrm() {
        python_mod_cleanup "/usr/$(get_libdir)/entropy/${PN}"
	gnome2_gconf_savelist
	gnome2_gconf_uninstall
}

