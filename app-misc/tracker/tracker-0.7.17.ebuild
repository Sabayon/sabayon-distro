# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/tracker/tracker-0.7.17.ebuild,v 1.4 2010/02/15 16:52:47 lxnay Exp $

EAPI="2"
G2CONF_DEBUG="no"

inherit gnome2 linux-info

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="http://www.tracker-project.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~sparc ~x86"
# USE="doc" is managed by eclass.
IUSE="applet deskbar doc eds exif gsf gstreamer gtk hal iptc +jpeg kmail laptop mp3 nautilus pdf playlist test +tiff +vorbis xine +xml xmp"

# Automagic, gconf, uuid, enca and probably more
# TODO: quill and streamanalyzer support
RDEPEND="
	>=app-i18n/enca-1.9
	>=dev-db/sqlite-3.6.16[threadsafe]
	>=dev-libs/dbus-glib-0.82-r1
	>=dev-libs/glib-2.20
	>=gnome-base/gconf-2
	>=media-gfx/imagemagick-5.2.1[png,jpeg=]
	>=media-libs/libpng-1.2
	>=x11-libs/pango-1
	sys-apps/util-linux

	applet? (
		>=x11-libs/libnotify-0.4.3
		gnome-base/gnome-panel
		>=x11-libs/gtk+-2.16 )
	deskbar? ( >=gnome-extra/deskbar-applet-2.19 )
	eds? (
		>=mail-client/evolution-2.25.5
		>=gnome-extra/evolution-data-server-2.25.5 )
	exif? ( >=media-libs/libexif-0.6 )
	iptc? ( media-libs/libiptcdata )
	jpeg? ( media-libs/jpeg:0 )
	gsf? ( >=gnome-extra/libgsf-1.13 )
	gstreamer? ( >=media-libs/gstreamer-0.10.12 )
	!gstreamer? ( !xine? ( || ( media-video/totem media-video/mplayer ) ) )
	gtk? ( >=x11-libs/gtk+-2.16.0 )
	laptop? (
		hal? ( >=sys-apps/hal-0.5 )
		!hal? ( >=sys-apps/devicekit-power-007 ) )
	mp3? ( >=media-libs/id3lib-3.8.3 )
	nautilus? ( gnome-base/nautilus )
	pdf? (
		>=x11-libs/cairo-1
		>=app-text/poppler-0.12.3-r3[cairo,utils]
		>=x11-libs/gtk+-2.12 )
	playlist? ( dev-libs/totem-pl-parser )
	tiff? ( media-libs/tiff )
	vorbis? ( >=media-libs/libvorbis-0.22 )
	xine? ( >=media-libs/xine-lib-1 )
	xml? ( >=dev-libs/libxml2-2.6 )
	xmp? ( >=media-libs/exempi-2.1 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.14
	>=dev-util/pkgconfig-0.20
	applet? (
		dev-lang/vala
		>=dev-libs/libgee-0.3 )
	gtk? (
		dev-lang/vala
		>=dev-libs/libgee-0.3 )
	doc? (
		>=dev-util/gtk-doc-1.8
		media-gfx/graphviz )"
#	test? ( gcov )

DOCS="AUTHORS ChangeLog NEWS README"

# FIXME: find if it is a tracker or gtester bug and report
# Tests fail when run in sequence, but succeed when called individually
RESTRICT="test"

function inotify_enabled() {
	if linux_config_exists; then
		if ! linux_chkconfig_present INOTIFY_USER; then
			echo
			ewarn "You should enable the INOTIFY support in your kernel."
			ewarn "Check the 'Inotify support for userland' under the 'File systems'"
			ewarn "option. It is marked as CONFIG_INOTIFY_USER in the config"
			echo
			die 'missing CONFIG_INOTIFY'
		fi
	else
		einfo "Could not check for INOTIFY support in your kernel."
	fi
}

pkg_setup() {
	linux-info_pkg_setup

	inotify_enabled

	if use gstreamer ; then
		G2CONF="${G2CONF}
			--enable-video-extractor=gstreamer
			--enable-gstreamer-tagreadbin"
		# --enable-gstreamer-helix (real media)
	elif use xine ; then
		G2CONF="${G2CONF} --enable-video-extractor=xine"
	else
		G2CONF="${G2CONF} --enable-video-extractor=external"
	fi

	# hal and dk-p are used for AC power detection
	if use laptop; then
		G2CONF="${G2CONF} $(use_enable hal) $(use_enable !hal devkit-power)"
	else
		G2CONF="${G2CONF} --disable-hal --disable-devkit-power"
	fi

	if use nautilus; then
		G2CONF="${G2CONF} --enable-nautilus-extension=yes"
	else
		G2CONF="${G2CONF} --enable-nautilus-extension=no"
	fi

	G2CONF="${G2CONF}
		--disable-unac
		--disable-functional-tests
		$(use_enable applet tracker-status-icon)
		$(use_enable applet tracker-search-bar)
		$(use_enable deskbar deskbar-applet)
		$(use_enable eds evolution-miner)
		$(use_enable exif libexif)
		$(use_enable gsf libgsf)
		$(use_enable gtk libtrackergtk)
		$(use_enable gtk tracker-explorer)
		$(use_enable gtk tracker-preferences)
		$(use_enable gtk tracker-search-tool)
		$(use_enable iptc libiptcdata)
		$(use_enable jpeg libjpeg)
		$(use_enable kmail kmail-miner)
		$(use_enable mp3 id3lib)
		$(use_enable pdf poppler-glib)
		$(use_enable playlist)
		$(use_enable test unit-tests)
		$(use_enable tiff libtiff)
		$(use_enable vorbis libvorbis)
		$(use_enable xml libxml2)
		$(use_enable xmp exempi)"
		# FIXME: Missing files to run functional tests
		# $(use_enable test functional-tests)
		# FIXME: useless without quill (extract mp3 albumart...)
		# $(use_enable gtk gdkpixbuf)
}

src_test() {
	export XDG_CONFIG_HOME="${T}"
	emake check || die "tests failed"
}
