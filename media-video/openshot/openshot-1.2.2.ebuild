# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

PYTHON_DEPEND=2:2.5
PYTHON_USE_WITH=xml

inherit distutils fdo-mime python

DESCRIPTION="OpenShot Video Editor is a non-linear video editor"
HOMEPAGE="http://www.openshotvideo.com"
SRC_URI="http://launchpad.net/openshot/1.2/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dv faac flac ieee1394 mp3 ogg quicktime theora vorbis wavpack x264 xvid"

DEPEND=""
RDEPEND="
	>=x11-libs/gtk+-2.18
	dev-python/pygtk
	dev-python/pygoocanvas
	dev-python/pyxdg
	dev-python/librsvg-python
	>=media-libs/mlt-0.4.6-r1[dv?,ffmpeg,frei0r,gtk,melt,python,quicktime?,sdl,vorbis?,xml]
	media-sound/sox[encode,ffmpeg,flac?,ogg?,wavpack?]
	>=media-video/ffmpeg-0.6[encode,faac?,ieee1394?,mp3?,sdl,theora?,vorbis?,vpx,x264?,xvid?]
	"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	python_convert_shebangs -q -r 2 .
	distutils_src_prepare

	# Disable the installation of the mime.types file.
	# The .desktop file would be used to update the mime database.
	sed -ie '/launcher/,+1d' setup.py || die

	# Avoid stuff covered by fdo-mime.eclass
	# (update-mime-database update-desktop-database update-mime)
	# export "FAKEROOTKEY=gentoo" does not work as this variable is filtered
	# by portage
	sed -ie '/FAILED = /,$d' setup.py || die
}

# TODO: check stuff installed to /usr/lib/python2.6/site-packages as there are
# some parts installed which shouldn't (locale, themes, profiles effects,
# etc...) Afaik only python stuff should go there and the rest probably to
# /usr/share/openshot
# The same goes for /usr/lib/mime/packages

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	distutils_pkg_postinst
}

pkg_postrm() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	distutils_pkg_postrm
}
