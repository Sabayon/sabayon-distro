# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit python eutils distutils

DESCRIPTION="An open source cross platform media center solution that uses GStreamer multimedia framework."
HOMEPAGE="http://elisa.fluendo.com"
SRC_URI="http://elisa.fluendo.com/static/download/elisa/${P}.tar.gz"

LICENSE="GPL-2.1 MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/setuptools
	dev-python/imaging
	>=dev-python/twisted-2.2
	dev-python/gnome-python-extras
	media-libs/pigment
	>=dev-python/twisted-web-0.6
	dev-python/Coherence

	>=dev-db/sqlite-3.2.8
	>=dev-python/pysqlite-2.0.5

	media-libs/libdvdcss
	media-libs/gst-plugins-ugly
	media-plugins/gst-plugins-ffmpeg
	"
# media-libs/gst-plugins-bad

RDEPEND="${DEPEND}"
