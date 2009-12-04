# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

GCONF_DEBUG="no"

inherit autotools eutils gnome2

DESCRIPTION="Gobject-Introspection file Repository"
HOMEPAGE="http://live.gnome.org/GObjectIntrospection/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="atk avahi babl dbus gconf gnome-keyring goocanvas +gtk gtksourceview gupnp
libnotify libsoup libwnck nautilus pango poppler vte webkit"

RDEPEND=">=dev-libs/gobject-introspection-0.6.5"
DEPEND="${RDEPEND}
	atk? ( >=dev-libs/atk-1.12.0 )
	avahi? ( >=net-dns/avahi-0.6 )
	babl? ( media-libs/babl )
	dbus? ( dev-libs/dbus-glib )
	gconf? ( gnome-base/gconf )
	gnome-keyring? ( gnome-base/gnome-keyring )
	goocanvas? ( x11-libs/goocanvas )
	gtk? (
		>=dev-libs/atk-1.12.0
		x11-libs/gtk+:2 )
	gtksourceview? ( x11-libs/gtksourceview )
	gupnp? (
		net-libs/gssdp
		net-libs/gupnp )
	libnotify? ( x11-libs/libnotify )
	libsoup? ( net-libs/libsoup:2.4 )
	libwnck? ( x11-libs/libwnck )
	nautilus? ( gnome-base/nautilus )
	pango? ( x11-libs/pango )
	poppler? ( >=virtual/poppler-glib-0.8 )
	vte? ( x11-libs/vte )
	webkit? ( >=net-libs/webkit-gtk-1.0 )
"

_auto_dep() {
	if use ${1} && ! use ${2}; then
		ewarn "${2} is disabled, but ${1} needs ${2}. Auto-enabling..."
		G2CONF="${G2CONF} --enable-${3:-$2}"
	fi
}

pkg_setup() {
	# FIXME: installs even disabled stuff if it's a dependency of something enabled
	G2CONF="${G2CONF}
		--disable-clutter
		--disable-clutter-gtk
		--disable-clutter-cairo
		--disable-gnio
		--disable-gstreamer
		--disable-unique
		$(use_enable atk)
		$(use_enable avahi)
		$(use_enable babl)
		$(use_enable dbus)
		$(use_enable gconf)
		$(use_enable gnome-keyring gnomekeyring)
		$(use_enable goocanvas)
		$(use_enable gtk)
		$(use_enable gtksourceview)
		$(use_enable gupnp gssdp)
		$(use_enable libnotify notify)
		$(use_enable libsoup soup)
		$(use_enable libwnck wnck)
		$(use_enable nautilus)
		$(use_enable pango)
		$(use_enable poppler)
		$(use_enable vte)
		$(use_enable webkit)
	"

	# XXX: Auto-enabling is for Makefile-level dependencies
	# FIXME: these dependencies are incomplete
	_auto_dep gtk atk
	_auto_dep gtk pango
	_auto_dep webkit libsoup soup
}

src_prepare() {
	gnome2_src_prepare

	epatch "${FILESDIR}/${P}-fix-worlds-worst-automagic-configure.patch"

	eautoreconf
}
