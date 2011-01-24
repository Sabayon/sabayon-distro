# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils versionator gnome2

DESCRIPTION="Me TV is a GTK desktop application for watching digital television."
HOMEPAGE="http://me-tv.sourceforge.net/"
SRC_URI="http://launchpad.net/${PN}/$(get_version_component_range 1-2)/$(get_version_component_range 1-3)/+download/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug doc nls static"
RDEPEND=">=dev-cpp/libgnomemm-2.20.0
	>=dev-cpp/libgnomecanvasmm-2.20.0
	>=dev-cpp/libgnomeuimm-2.20.0
	>=dev-cpp/gconfmm-2.20.0
	>=dev-cpp/gtkmm-2.16.0
	=dev-db/sqlite-3*
	>=net-libs/gnet-2.0.0
	>=x11-libs/libXtst-1.0.0
	>=media-libs/xine-lib-1.1.7"

DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.0 )"

#S="${WORKDIR}/${PN}-0.8.0"

src_prepare() {
	econf \
	      $(use_enable nls) \
	      $(use_enable debug) \
	      $(use_enable doc gtk-doc) \
	      || die "econf failed"
}

src_compile() {
	      gnome2_src_compile
}

