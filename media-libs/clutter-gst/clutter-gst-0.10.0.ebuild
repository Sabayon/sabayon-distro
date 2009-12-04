# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit clutter

DESCRIPTION="GStreamer Integration library for Clutter"

SLOT="1.0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

RDEPEND="
	media-libs/clutter:1.0
	media-libs/gstreamer:0.10
	media-libs/gst-plugins-base:0.10"
DEPEND="${RDEPEND}
	virtual/python"

DOCS="AUTHORS ChangeLog NEWS README"
EXAMPLES="examples/{*.c,*.png,README}"
