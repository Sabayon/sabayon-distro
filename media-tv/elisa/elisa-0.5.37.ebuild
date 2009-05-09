# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils python

DESCRIPTION="Elisa is an open source, cross platform media center solution for Linux, MacOSX and Windows on top of GStreamer."
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/${PN}/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE="daap doc dvd hal ipod flash lirc upnp weather"

MAKEOPTS="-j1"

RDEPEND=">=dev-lang/python-2.5
	dev-python/setuptools
	>=dev-python/imaging-1
	>=dev-python/twisted-2.2
	dev-python/twisted-web
	dev-python/twisted-web2
	dev-python/pyopenssl
	dev-python/pygtk
	dev-python/gnome-python-extras
	>=dev-python/pigment-python-0.3.8
	>=media-libs/gstreamer-0.10.4
	>=dev-python/gst-python-0.10
	>=media-plugins/gst-plugins-ogg-0.10
	>=media-plugins/gst-plugins-vorbis-0.10
	>=media-plugins/gst-plugins-theora-0.10
	media-plugins/libvisual-plugins:0.4
	media-fonts/freefont-ttf
	x11-misc/xdg-user-dirs
	dev-python/pyxdg
	dev-python/celementtree
	dev-python/pysqlite
	dev-python/pycairo
	dev-python/simplejson
	dvd? (
		media-libs/libdvdcss
		>=media-plugins/gst-plugins-ffmpeg-0.10
		>=media-libs/gst-plugins-bad-0.10
		>=media-libs/gst-plugins-ugly-0.10
		dev-python/tagpy
	)
	flash? (
		>=media-plugins/gst-plugins-ffmpeg-0.10
		>=media-libs/gst-plugins-bad-0.10
		dev-python/gdata
	)
	lirc? (
		app-misc/lirc
		dev-python/pylirc
	)
	daap? (
		dev-python/python-daap
		>=sys-apps/dbus-1
		>=dev-python/dbus-python-0.71
		>=net-dns/avahi-0.6
	)
	hal? (
		>=sys-apps/hal-0.5
		>=dev-python/dbus-python-0.71
	)
	ipod? (
		media-libs/libgpod
	)
	upnp? (
		dev-python/Coherence
	)
	weather? (
		dev-python/pymetar
	)"


DEPEND="${DEPEND}
	>=dev-util/pkgconfig-0.9"

PDEPEND=">=media-plugins/elisa-plugins-good-${PV}
	>=media-plugins/elisa-plugins-bad-${PV}
	>=media-plugins/elisa-plugins-ugly-${PV}"

DOCS="AUTHORS ChangeLog COPYING NEWS FIRST_RUN"

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

pkg_preinst()
{
    # HACKY but we must Nuke the *very old* elisa dir to make sure we dont get errors!
	rm -rf /usr/lib64/python2.5/site-packages/elisa*
}

pkg_postinst() {

	einfo "After first run of the box, edit elisa.conf and add some media"
	einfo "locations in [xmlmenu:locaions_builder]"
	einfo "e.g."
	einfo "locations = ['file://./sample_data/pictures', 'file:///media/videos']"
	einfo ""
	einfo "If you get failures loading plugins, delete ~/.elisa"
	einfo ""
	einfo "Please replace gstreamer:gst_metadata_client with"
	einfo "gstreamer:gst_metadata in your ~/.elisa/elisa.conf to get song"
	einfo "metadata scanning"

}
