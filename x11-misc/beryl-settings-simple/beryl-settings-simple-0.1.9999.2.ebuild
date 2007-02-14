# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit autotools flag-o-matic eutils 

IUSE=""

DESCRIPTION="Beryl Settings Utility (Simple Edition)"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND=">=x11-libs/gtk+-2.8.0
	~x11-wm/beryl-core-${PV}
	>=gnome-base/librsvg-2.16.1"

RDEPEND="~x11-misc/beryl-settings-bindings-${PV}"

src_compile() {
	econf || die "econf failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
