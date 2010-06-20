# Copyright 2000-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils gnome2

DESCRIPTION="The new Desktop Menu from SuSE Linux Enterprise by Novell"
HOMEPAGE="http://www.novell.com/products/desktop/preview.html"
SRC_URI="http://archive.ubuntu.com/ubuntu/pool/universe/g/gnome-main-menu/${PN}_${PV}.orig.tar.gz
	http://archive.ubuntu.com/ubuntu/pool/universe/g/gnome-main-menu/${PN}_${PV}-1.debian.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc nautilus"

RDEPEND=">=dev-libs/glib-2.16.0
	>=x11-libs/gtk+-2
	>=gnome-base/libglade-2
	>=gnome-base/gnome-desktop-2
	>=gnome-base/gnome-panel-2
	>=gnome-base/librsvg-2
	>=gnome-base/gnome-menus-2
	>=gnome-base/gconf-2
	>=gnome-base/libgtop-2
	>=gnome-base/libgnome-2
	>=gnome-base/libgnomeui-2
	gnome-base/libslab
	dev-libs/dbus-glib
	>=net-misc/networkmanager-0.8
	sys-apps/hal
	x11-libs/cairo
	x11-libs/pango
	nautilus? ( >=gnome-base/nautilus-2.6
		>=gnome-base/gnome-vfs-2 )"

DEPEND="${RDEPEND}
	doc? (
		dev-util/gtk-doc
	)"

src_unpack() {
	gnome2_src_unpack
	cd "${S}"
	epatch "${WORKDIR}"/debian/patches/*.{patch,diff}

	gnome2_omf_fix

	G2CONF="`use_enable nautilus nautilus-extension`"
	intltoolize --force || die "intloolize failed"
	eautoreconf || die "eautoreconf failed"
}

pkg_postinst() {

	elog
	elog " If you want to have recent applications-support working, you should "
	elog " also use the patched gnome-panel and gnome-desktop packages from this "
	elog " overlay "
	elog
}
