# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit enlightenment

DESCRIPTION="utility for taking screenshots of the entire screen"

KEYWORDS="~amd64 ~x86"

RDEPEND="x11-libs/libX11
	>=dev-libs/ecore-9999
	>=media-libs/evas-9999
	>=dev-libs/eina-9999
	>=media-libs/edje-9999
	media-libs/imlib"
DEPEND="${RDEPEND}
	x11-proto/xproto"
