# Copyright 2006-2007 BreakMyGentoo.org
# Copyright 2008 Daniel Gryniewcz
# Distributed under the terms of the GNU General Public License v2

inherit distutils python

DESCRIPTION="Elisa is an open source, cross platform media center solution for Linux, MacOSX and Windows on top of GStreamer."
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/${PN}/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE="daap doc dvd ipod lirc"

MAKEOPTS="-j1"

RDEPEND=">=dev-lang/python-2.5
	dev-python/setuptools
	>=dev-python/imaging-1
	>=dev-python/twisted-2.2
	dev-python/twisted-web
	dev-python/gnome-python-extras
	dev-python/pygtk
	>=media-libs/pigment-0.3.5
	>=dev-python/pigment-python-0.3.3
	>=media-libs/gstreamer-0.10.4
	>=dev-python/gst-python-0.10
	>=media-plugins/gst-plugins-ogg-0.10
	>=media-plugins/gst-plugins-vorbis-0.10
	>=media-plugins/gst-plugins-theora-0.10
	media-plugins/libvisual-plugins:0.4
	dev-python/pyxdg
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

PDEPEND=">=media-plugins/elisa-plugins-good-${PV}
	>=media-plugins/elisa-plugins-bad-${PV}
	>=media-plugins/elisa-plugins-ugly-${PV}"

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

	addpredict "/root/.gstreamer-0.10"
}

pkg_postinst() {

	einfo "After first run of the box, edit elisa.conf and add some media"
	einfo "locations in [xmlmenu:locaions_builder]"
	einfo "e.g."
	einfo "locations = ['file://./sample_data/pictures', 'file:///media/videos']"
	einfo ""
	einfo "If you get failures loading plugins, delete ~/.elisa"

}
