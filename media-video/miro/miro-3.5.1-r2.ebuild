# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2:2.6"

inherit fdo-mime gnome2-utils python distutils

DESCRIPTION="Open source video player and podcast client"
HOMEPAGE="http://www.getmiro.com/"
SRC_URI="http://ftp.osuosl.org/pub/pculture.org/${PN}/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify faac faad +ffmpeg mp3 musepack theora vorbis x264 xvid"

CDEPEND="
	dev-libs/glib:2
	dev-libs/boost[python]
	>=dev-python/pyrex-0.9.6.4
	dev-python/pygtk:2
	dev-python/pygobject:2
	>=net-libs/webkit-gtk-1.1.15"

RDEPEND="${CDEPEND}
	libnotify? ( dev-python/notify-python )
	|| ( =dev-lang/python-2*[sqlite] dev-python/pysqlite:2 )
	dev-python/dbus-python
	dev-python/pycairo
	>=dev-python/pywebkitgtk-1.1.5
	dev-python/pycurl
	dev-python/gconf-python
	dev-python/gst-python:0.10
	net-libs/rb_libtorrent[python]
	media-plugins/gst-plugins-meta:0.10[theora?,vorbis?]
	=media-plugins/gst-plugins-pango-0.10*
	faad? ( =media-plugins/gst-plugins-faad-0.10* )
	mp3? ( =media-plugins/gst-plugins-mad-0.10* )
	musepack? ( =media-plugins/gst-plugins-musepack-0.10* )
	x264? ( =media-plugins/gst-plugins-x264-0.10* )
	xvid? ( =media-plugins/gst-plugins-xvid-0.10* )
	ffmpeg?	( >media-video/ffmpeg-0.6[faac?,mp3?,theora?,vorbis?,x264?,xvid?] )
	theora? ( media-video/ffmpeg2theora )"

DEPEND="${CDEPEND}"

S="${WORKDIR}/${P}/linux"

src_prepare() {
	# Fix the codec used to convert to ogg audio
	sed -i -e s/vorbis/libvorbis/ ../resources/conversions/others.conv
}

src_install() {
	# doing the mv now otherwise, distutils_src_install will install it
	mv README README.gtk || die "mv failed"

	distutils_src_install

	# installing docs
	dodoc README.gtk ../{ADOPTERS,CREDITS,README} || die "dodoc failed"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update

	ewarn
	ewarn "If miro doesn't play some video or audio format, please"
	ewarn "check your USE flags on media-plugins/gst-plugins-meta"
	ewarn
	elog "Miro for Linux doesn't support Adobe Flash, therefore you"
	elog "you will not see any embedded video player on MiroGuide."
	elog
}

pkg_postrm() {
	distutils_pkg_postrm
	gnome2_icon_cache_update
}
