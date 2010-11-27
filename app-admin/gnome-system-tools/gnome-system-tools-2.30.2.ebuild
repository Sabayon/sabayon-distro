# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gnome-system-tools/gnome-system-tools-2.30.2.ebuild,v 1.6 2010/09/19 16:42:51 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Tools aimed to make easy the administration of UNIX systems"
HOMEPAGE="http://www.gnome.org/projects/gst/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~ia64 ppc ~sparc x86"
IUSE="nfs +network policykit +services +time samba +users"

RDEPEND="
	>=app-admin/system-tools-backends-2.9.4
	>=dev-libs/liboobs-2.29.91
	>=x11-libs/gtk+-2.18:2
	>=dev-libs/glib-2.15.2:2
	>=gnome-base/gconf-2.2
	dev-libs/dbus-glib
	>=gnome-base/nautilus-2.9.90
	sys-libs/cracklib
	nfs? ( net-fs/nfs-utils )
	samba? ( >=net-fs/samba-3 )
	policykit? (
		>=sys-auth/polkit-0.92
		>=gnome-extra/polkit-gnome-0.92 )"

DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=app-text/gnome-doc-utils-0.3.2
	dev-util/pkgconfig
	>=dev-util/intltool-0.35.0"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable network)
		$(use_enable policykit polkit-gtk)
		$(use_enable services)
		$(use_enable time)
		$(use_enable users)"

	if ! use nfs && ! use samba; then
		G2CONF="${G2CONF} --disable-shares"
	fi
}

src_install() {
	gnome2_src_install

	# No la files needed for nautilus-extensions
	find "${D}" -name "*.la" -delete || die "failed to delete *.la files"
}
