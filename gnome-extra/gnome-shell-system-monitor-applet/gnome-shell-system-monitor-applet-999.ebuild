# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils git-2 fdo-mime gnome2-utils

DESCRIPTION="GNOME Shell System Monitor Extension"
HOMEPAGE="https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="gnome-base/gnome-shell
	gnome-base/gsettings-desktop-schemas"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${DEPEND} ${COMMON_DEPEND}"

EGIT_REPO_URI="git://github.com/paradoxxxzero/gnome-shell-system-monitor-applet.git"
EGIT_COMMIT="0ae50194721a9d337665b8b8f192cc64b1491478"

src_install()	{
	dodir /usr/share/gnome-shell/extensions
	insinto /usr/share/gnome-shell/extensions
	doins -r system-monitor@paradoxxx.zero.gmail.com

	exeinto /usr/bin
	mv system-monitor-applet-config.py system-monitor-applet-config || die
	doexe system-monitor-applet-config

	domenu system-monitor-applet-config.desktop

	insinto /usr/share/glib-2.0/schemas
	doins org.gnome.shell.extensions.system-monitor.gschema.xml
}

pkg_preinst() {
	gnome2_gconf_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_gconf_install
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_schemas_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_schemas_update --uninstall
}
