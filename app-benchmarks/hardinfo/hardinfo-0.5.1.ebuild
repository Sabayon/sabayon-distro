# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/menelkir/portage/app-benchmark/hardinfo/hardinfo-0.5.1.ebuild,v 0.5.1  2010/05/31 10:20:14 menelkir Exp $

EAPI="2"

inherit eutils

DESCRIPTION="HardInfo is a system information and benchmark tool for Linux systems"
HOMEPAGE="http://hardinfo.berlios.de/"
SRC_URI="http://download.berlios.de/hardinfo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.6:2
>=net-libs/libsoup-2.4"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P}"

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_compile() {
	econf --prefix=/usr || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
