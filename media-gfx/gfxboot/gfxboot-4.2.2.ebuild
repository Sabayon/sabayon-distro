# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=2

inherit eutils

DESCRIPTION="gfxboot allows you to create gfx menus for bootmanagers."
HOMEPAGE="http://www.sabayon.org"
SRC_URI="mirror://ubuntu/pool/main/g/gfxboot/gfxboot_${PV}.orig.tar.gz
	mirror://ubuntu/pool/main/g/gfxboot/gfxboot_${PV}-1ubuntu1.diff.gz"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="app-arch/cpio
	dev-lang/nasm
	>=media-libs/freetype-2
	app-text/xmlto
	dev-libs/libxslt
	app-text/docbook-xml-dtd:4.1.2
	dev-perl/HTML-Parser"
RDEPEND="${DEPEND}"
RESTRICT="mirror"

src_prepare() {
	epatch "${WORKDIR}/gfxboot_${PV}-1ubuntu1.diff"
	epatch "${S}/${P}/debian/patches/"*.patch
	# force executables into /usr/bin, as Ubuntu does
	sed -i "s:usr/sbin:usr/bin:g" "${S}/Makefile" || die
}

src_install() {
	dodir /etc/bootsplash/themes
	emake DESTDIR="${D}" THEMES="" install || die
}
