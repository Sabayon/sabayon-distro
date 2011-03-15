# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit enlightenment

DESCRIPTION="library for handling of freedesktop.org specs (desktop/icon/theme/etc...)"
RDEPEND="
	>=dev-libs/ecore-9999
	>=dev-libs/eet-9999
	>=dev-libs/eina-9999
	x11-misc/xdg-utils"
DEPEND="${RDEPEND}"

KEYWORDS="~amd64 ~x86"

IUSE="cache static-libs"

src_configure() {
	local MY_ECONF="$(use_enable cache icon-cache)"
	enlightenment_src_configure
}
