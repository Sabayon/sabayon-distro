# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit autotools gnome2

DESCRIPTION="Fully customisable dock-like window navigator for GNOME."
HOMEPAGE="http://code.google.com/p/avant-window-navigator/"
SRC_URI="http://avant-window-navigator.googlecode.com/files/${PN}-0.1.1-2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-libs/libwnck-2.16.2
	gnome-base/gnome-common"

src_unpack() {
	gnome2_src_unpack
	intltoolize --force || die "intltool failed"
}

src_compile() {
	eautoreconf

	gnome_src_compile

	emake -j1 || die "emake fail"
}

src_install() {
	gnome_src_install
}
