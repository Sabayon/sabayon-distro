# Copyright 2006-2007 BreakMyGentoo.org
# Distributed under the terms of the GNU General Public License v2

inherit distutils python eutils

DESCRIPTION="Elisa is an open source, cross platform media center solution for Linux, MacOSX and Windows on top of GStreamer."
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/${PN}/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE="daap doc dvd ipod lirc upnp"

MAKEOPTS="-j1"

RDEPEND=">=dev-lang/python-2.4
	dev-python/setuptools
	>=dev-python/imaging-1
	>=dev-python/twisted-2.2
	dev-python/gnome-python-extras
	>=media-libs/gstreamer-0.10.4
	>=dev-python/gst-python-0.10
	>=media-plugins/gst-plugins-ogg-0.10
	>=media-plugins/gst-plugins-vorbis-0.10
	>=media-plugins/gst-plugins-theora-0.10
	>=media-libs/pigment-0.3
	>=dev-db/sqlite-3.2.8
	>=dev-python/pysqlite-2.0.5
	upnp? (
		dev-python/twisted-web
		dev-python/elementtree
		dev-python/celementtree
		dev-python/soappy
	)
	dvd? (
		media-libs/libdvdcss
		>=media-plugins/gst-plugins-ffmpeg-0.10
		>=media-libs/gst-plugins-bad-0.10
		>=media-libs/gst-plugins-ugly-0.10
		dev-python/tagpy
	)
	lirc? (
		app-misc/lirc
		dev-python/pylirc
	)
	daap? (
		dev-python/PythonDaap
		>=sys-apps/dbus-1
		>=dev-python/dbus-python-0.71
		>=net-dns/avahi-0.6
	)
	ipod? (
		media-libs/libgpod
		>=sys-apps/dbus-1
		>=dev-python/dbus-python-0.71
		>=sys-apps/hal-0.5
	)"


DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog COPYING NEWS"

pkg_setup() {
	if use daap ; then
		if built_with_use net-dns/avahi python ; then
			einfo "Avahi Python bindings found ..."
		else
			eerror "Please rebuild net-dns/avahi with python support enabled!"
			eerror "Try USE=\"python\" emerge net-dns/avahi,"
			eerror "or add \"python\" to your USE string in /etc/make.conf and"
			eerror "emerge net-dns/avahi."
			die "USE flag \"python\" must be enabled in net-dns/avahi"
		fi
	fi


	if use ipod ; then
		if built_with_use media-libs/libgpod python ; then
			einfo "libgpod Python bindings found ..."
		else
			eerror "Please rebuild media-libs/libgpod with python support enabled!"
			eerror "Try USE=\"python\" emerge media-libs/libgpod,"
			eerror "or add \"python\" to your USE string in /etc/make.conf and"
			eerror "emerge media-libs/libgpod."
			die "USE flag \"python\" must be enabled in media-libs/libgpod"
		fi
	fi
}

src_unpack() {
	unpack "${A}"
	cd "${S}"
	#epatch "${FILESDIR}/${PN}-0.1.6-defaults.patch"
}

pkg_postinst() {

	einfo "After first run of the box, edit elisa.conf and add some media"
	einfo "locations in [movies], [music] and [pictures] config sections"
	einfo "e.g."
	einfo "[plugins.pictures]"
	einfo "locations = ['file://./sample_data/pictures',]"
	einfo ""
	einfo "[plugins.movies]"
	einfo "locations = ['file://./sample_data/movies', 'file:///data/movies/', 'smb://mediaserver/movies/']"
	einfo ""
	einfo "[plugins.music]"
	einfo "locations = ['file://./sample_data/music', 'file:///data/music/']"

}

