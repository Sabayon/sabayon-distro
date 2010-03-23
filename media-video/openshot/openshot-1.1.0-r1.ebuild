# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

PYTHON_DEPEND=2
PYTHON_USE_WITH=xml

inherit distutils fdo-mime python

DESCRIPTION="OpenShot Video Editor is a non-linear video editor"
HOMEPAGE="http://www.openshotvideo.com"
SRC_URI="http://launchpad.net/openshot/1.1/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="faac faad ieee1394 jack mp3 quicktime theora vorbis x264"

DEPEND=""
RDEPEND="
	dev-python/pygtk
	dev-python/pygoocanvas
	dev-python/pyxdg
	gnome-base/librsvg
	>=media-libs/mlt-0.4.6-r1[dv,ffmpeg,frei0r,melt,python,quicktime?,sdl,xml]
	media-sound/sox[encode,ffmpeg]
	media-video/ffmpeg[encode,ieee1394?,jack?,x264?,vorbis?,theora?,faac?,faad?,mp3?]"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	distutils_src_prepare

	# Avoid stuff covered by fdo-mime.eclass
	# (update-mime-database update-desktop-database update-mime)
	# export "FAKEROOTKEY=gentoo" does not work as this variable is filtered
	# by portage
	sed -i -e '/FAILED = /q' setup.py
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
