# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/plymouth"
	AUTOTOOLS_AUTORECONF="1"
	inherit git-r3
	SRC_URI=""
else
	SRC_URI="http://www.freedesktop.org/software/plymouth/releases/${P/-extras}.tar.bz2"
fi

inherit autotools-utils systemd toolchain-funcs

DESCRIPTION="X11 and Label plugins for Plymouth"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"

LICENSE="GPL-2"
SLOT="0"
[[ ${PV} == 9999 ]] || \
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
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
