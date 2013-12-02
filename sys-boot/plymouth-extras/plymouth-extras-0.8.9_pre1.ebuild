# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="git://anongit.freedesktop.org/plymouth"
EGIT_COMMIT="37d2e400d25e6b4716d77d26fb7d40de8a8c1a8a"
AUTOTOOLS_AUTORECONF="true"

inherit autotools-utils systemd toolchain-funcs git-2

DESCRIPTION="X11 and Label plugins for Plymouth"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug static-libs"

CDEPEND=">=media-libs/libpng-1.2.16
	dev-libs/glib
	>=x11-libs/gtk+-2.12:2
	>=x11-libs/pango-1.21
	~sys-boot/plymouth-${PV}[-gtk,-pango,debug=]"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	"
RDEPEND="${CDEPEND}"

S="${WORKDIR}/${P/-extras}"

src_configure() {
	local myeconfargs=(
		--with-system-root-install
		--localstatedir=/var
		--enable-gtk
		--enable-pango
		$(use_enable debug tracing)
		)
	autotools-utils_src_configure
}

src_install() {
	local build_dir="${BUILD_DIR}"

	# Build the x11 plugin
	BUILD_DIR="${build_dir}/src/plugins/renderers/x11" autotools-utils_src_install

	# Build the label plugin
	BUILD_DIR="${build_dir}/src/plugins/controls/label" autotools-utils_src_install
}
