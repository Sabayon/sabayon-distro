# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit eutils gnome2-utils fdo-mime python git

DESCRIPTION="Official Sabayon Linux Package Manager Graphical Client (tagged release)"
HOMEPAGE="http://www.sabayonlinux.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	!app-admin/spritz
	>=dev-python/pygtk-2.12.1-r2
	>=x11-libs/vte-0.12.2[python]
	x11-misc/xdg-utils
	~sys-apps/entropy-${PV}"
DEPEND="sys-devel/gettext"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" -j1 sulfur-install || die "make install failed"
	dodir /etc/gconf/schemas
	insinto /etc/gconf/schemas
	doins "${S}/sulfur/misc/entropy-handler.schemas"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	gnome2_gconf_savelist
	gnome2_gconf_install
	python_mod_compile "/usr/$(get_libdir)/entropy/${PN}"
}

pkg_postrm() {
        python_mod_cleanup "/usr/$(get_libdir)/entropy/${PN}"
	gnome2_gconf_savelist
	gnome2_gconf_uninstall
}

