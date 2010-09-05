# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#EAPI="2"
inherit eutils

DESCRIPTION="Parental control tool"
HOMEPAGE="http://projects.gnome.org/nanny/"
SRC_URI="http://ftp.gnome.org/pub/GNOME/sources/nanny/2.29/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="x11-libs/gtk+
	media-libs/alsa-lib
	>=dev-lang/python-2.4
	dev-python/twisted
	dev-python/twisted-web
	>=gnome-base/gnome-desktop-2.26.0
	gnome-base/libglade
	gnome-base/libgtop
	x11-libs/pango
	dev-perl/Cairo
	dev-util/pkgconfig
	dev-python/imaging
	dev-python/hachoir-regex"

RDEPEND="${DEPEND}"

src_configure() {
	econf --with-init-scripts=gentoo

}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	elog "This is development version, so not everything"
	elog "may work. What is more, you have to learn how to"
	elog "use this program on your own. Good luck."
}
