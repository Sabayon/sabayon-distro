# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
EBZR_REPO_URI="lp:cairo-dock-plug-ins"

inherit autotools bzr

DESCRIPTION="Official plugins for cairo-dock"
HOMEPAGE="https://launchpad.net/cairo-dock-plug-ins/"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="alsa compiz exif gio gmenu gnome kde mail musicplayer network-monitor powermanager terminal tomboy webkit wifi xfce xgamma xklavier"

RDEPEND="
	~x11-misc/cairo-dock-${PV}
	alsa? ( media-libs/alsa-lib )
	exif? ( media-libs/libexif )
	gmenu? ( gnome-base/gnome-menus )
	kde? ( kde-base/kdelibs )
	terminal? ( x11-libs/vte )
	webkit? ( >=net-libs/webkit-gtk-1.0 )
	xfce? ( xfce-base/thunar )
	xgamma? ( x11-libs/libXxf86vm )
	xklavier? ( x11-libs/libxklavier )
"

DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	dev-util/pkgconfig
"

pkg_setup() {
	if use gio; then
		if ! use gmenu; then
			ewarn "gio requires gmenu, implicitly added"
		fi
	fi
}

src_prepare() {
	intltoolize --automake --copy --force || die "intltoolize failed"
	eautoreconf -isvf
}

# Additional config options
#dnd2share
#rssreader
#xrandr-in-show-desktop
#scooby-do
src_configure() {
	econf --disable-dependency-tracking       \
		--disable-old-gnome-integration       \
		$(use_enable alsa  alsa-mixer)        \
		$(use_enable compiz compiz-icon)      \
		$(use_enable exif)                    \
		$(use_enable gio gio-in-gmenu)        \
		$(use_enable gio gmenu)               \
		$(use_enable gmenu)                   \
		$(use_enable gnome gnome-integration) \
		$(use_enable kde kde-integration)     \
		$(use_enable mail)                    \
		$(use_enable musicplayer)             \
		$(use_enable network-monitor)         \
		$(use_enable powermanager)            \
		$(use_enable terminal)                \
		$(use_enable tomboy)                  \
		$(use_enable webkit weblets)          \
		$(use_enable wifi)                    \
		$(use_enable xfce  xfce-integration)  \
		$(use_enable xgamma)                  \
		$(use_enable xklavier keyboard-indicator)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
