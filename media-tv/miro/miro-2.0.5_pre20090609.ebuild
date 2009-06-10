# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib distutils confutils fdo-mime versionator

NIGHTLYDATE="20090609"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${NIGHTLYDATE}"
DESCRIPTION="The free open-source video platform."
HOMEPAGE="http://www.getmiro.com/"
SRC_URI="http://pculture.org/nightlies/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

EAPI="2"

IUSE="libnotify gstreamer xine"

RDEPEND=">=dev-python/pygtk-2.10
	|| ( >=dev-lang/python-2.5[berkdb,sqlite]
	     >=dev-python/pysqlite-2 )
	|| ( dev-python/gnome-python
		 dev-python/gconf-python )
	>=dev-python/gtkmozembed-python-2.19.1-r11
	x11-base/xorg-server	
	dev-python/dbus-python
	>=net-libs/xulrunner-1.9
	>=dev-python/pyrex-0.9.6.4
	media-gfx/imagemagick
	|| ( =net-libs/rb_libtorrent-0.13
		>=net-libs/rb_libtorrent-0.14[python] )
	dev-python/bsddb3
	libnotify? ( dev-python/notify-python dev-libs/poppler-glib )
	gstreamer? ( media-libs/gstreamer dev-python/gst-python media-libs/gst-plugins-good media-libs/gst-plugins-bad media-libs/gst-plugins-ugly media-plugins/gst-plugins-faad sci-libs/cblas-reference )
	xine? ( media-libs/xine-lib[aac] )"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}/platform/gtk-x11"


pkg_postinst() {
    ewarn ""
	ewarn "DBus must be running for this package to work"
	ewarn ""
	ewarn "The gstreamer or xine USE flag must be selected for this package to work"
	ewarn ""
	elog 
	elog "It is ok to select the gstreamer and xine USE flag at the same time"
	elog
	einfo ""
	einfo "To switch between gstreamer and xine playback:"
	einfo "1. open video in the top menu."
	einfo "2. Go into options"
	einfo "3. Go into playback"
	einfo "4. Select gstreamer or xine."
	einfo "5. Restart Miro for a change to take effect." 
	einfo ""
}

