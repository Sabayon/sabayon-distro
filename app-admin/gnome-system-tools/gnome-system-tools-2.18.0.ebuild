# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gnome-system-tools/gnome-system-tools-2.14.0.ebuild,v 1.15 2007/01/09 04:29:29 leio Exp $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=1.9
inherit gnome2 eutils autotools

DESCRIPTION="Tools aimed to make easy the administration of UNIX systems"
HOMEPAGE="http://www.gnome.org/projects/gst/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86"
IUSE="nfs samba"

RDEPEND="net-misc/openssh
	userland_GNU? ( sys-apps/shadow )
	>=x11-libs/gtk+-2.6
	>=gnome-base/libgnomeui-2.9.0
	>=gnome-base/libglade-2.4
	>=gnome-base/gconf-2.2
	>=dev-libs/libxml2-2.4.12
	>=gnome-base/nautilus-2.9.90
	>=app-admin/system-tools-backends-2.2.0
	nfs? ( net-fs/nfs-utils )
	samba? ( >=net-fs/samba-3 )"

DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=app-text/gnome-doc-utils-0.3.2
	dev-util/pkgconfig
	>=dev-util/intltool-0.34.2"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

# --enable-disks is not (still) supported for Gentoo
G2CONF="${G2CONF} --enable-boot --enable-services --enable-network"

pkg_setup() {

	if ! use nfs && ! use samba; then
		G2CONF="${G2CONF} --disable-shares"
	fi
}

src_unpack() {
	gnome2_src_unpack
	eautoconf
}
