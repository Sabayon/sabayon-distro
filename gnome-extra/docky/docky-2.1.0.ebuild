# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnome2-utils mono eutils

DESCRIPTION="Docky is a full fledged dock application that makes opening \
common applications and managing windows easier and quicker."
HOMEPAGE="https://launchpad.net/docky"
SRC_URI="http://launchpad.net/${PN}/2.1/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug nls"

RDEPEND="
	>=dev-dotnet/art-sharp-2.24.1
	>=dev-dotnet/atk-sharp-2.12.10
	>=dev-dotnet/dbus-glib-sharp-0.5.0:1
	>=dev-dotnet/dbus-sharp-0.7.0:1
	>=dev-dotnet/gconf-sharp-2.24.1
	>=dev-dotnet/gdk-sharp-2.12.10
	>=dev-dotnet/glade-sharp-2.12.10
	>=dev-dotnet/gio-sharp-0.0.1
	>=dev-dotnet/gnome-desktop-sharp-2.6.0-r1
	>=dev-dotnet/gnome-keyring-sharp-1.0.0-r2
	>=dev-dotnet/gnome-sharp-2.24.1
	>=dev-dotnet/gnomevfs-sharp-2.24.1
	>=dev-dotnet/gtk-sharp-2.12.10
	>=dev-dotnet/gtk-sharp-gapi-2.12.10
	>=dev-dotnet/mono-addins-0.5
	>=dev-dotnet/notify-sharp-0.4
	>=dev-dotnet/pango-sharp-2.12.10
	>=dev-dotnet/rsvg-sharp-2.24.0-r10
	>=dev-dotnet/wnck-sharp-2.24.0-r10
	>=dev-lang/mono-2.6.4-r1
	!<gnome-extra/gnome-do-plugins-0.8
"

DEPEND="
	${RDEPEND}
	>=dev-util/intltool-0.41.1
	>=dev-util/pkgconfig-0.25-r2
"

RESTRICT="primaryuri"

src_configure() {
	econf   $(use_enable debug) \
		$(use_enable nls) \
		--enable-release
}

src_compile() {
	econf
	emake || die "Build failed"
}

src_install() {
	emake install DESTDIR="${D}"  || die "Install failed"
}

pkg_preinst() { 
	gnome2_icon_savelist; 
}

pkg_postinst() { 
	gnome2_icon_cache_update; 
}

pkg_postrm() { 
	gnome2_icon_cache_update; 
}

