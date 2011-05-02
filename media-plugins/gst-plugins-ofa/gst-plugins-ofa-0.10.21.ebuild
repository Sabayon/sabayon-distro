# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gst-plugins-bad

KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=media-libs/libofa-0.9.3
	>=media-libs/gst-plugins-base-0.10.32"
DEPEND="${RDEPEND}"
