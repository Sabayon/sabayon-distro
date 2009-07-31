# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/galeon/galeon-2.0.7-r1.ebuild,v 1.1 2009/07/21 15:38:52 nirbheek Exp $

inherit gnome2 eutils

DESCRIPTION="A GNOME Web browser based on gecko (mozilla's rendering engine)"
HOMEPAGE="http://galeon.sourceforge.net"
SRC_URI="mirror://sourceforge/galeon/${P}.tar.bz2
	mirror://gentoo/${P}-patches.tar.lzma"

LICENSE="GPL-2"
IUSE="seamonkey xulrunner"
KEYWORDS="~amd64 ~ia64 ~ppc ~sparc ~x86"
SLOT="0"
RDEPEND=">=net-libs/xulrunner-1.9.1
	>=x11-libs/gtk+-2.4.0
	>=dev-libs/libxml2-2.6.6
	>=gnome-base/libgnomeui-2.5.2
	>=gnome-base/gnome-vfs-2
	>=gnome-base/gnome-desktop-2.10.0
	>=gnome-base/libglade-2.3.1"
DEPEND="${RDEPEND}
	app-text/rarian
	dev-util/pkgconfig
	>=dev-util/intltool-0.30
	>=sys-devel/gettext-0.11"

DOCS="AUTHORS ChangeLog FAQ README README.ExtraPrefs THANKS TODO NEWS"

src_unpack() {
	gnome2_src_unpack
	cd "${S}"
	for i in "${WORKDIR}/${P}-patches/*"; do
		epatch $i || die "patch $i failed"
	done

	# bug 275252, patch => no building with <1.9.1
	epatch "${FILESDIR}/${P}-build-with-xulrunner-1.9.1.patch"

	# bug 278917, patch from bug 263990
	epatch "${FILESDIR}/${P}-moz191.patch"


}

src_compile() {
	myconf="--with-mozilla=libxul-embedding-unstable"

	econf ${myconf} || die "configure failed"
	emake || die "compile failed"
}
