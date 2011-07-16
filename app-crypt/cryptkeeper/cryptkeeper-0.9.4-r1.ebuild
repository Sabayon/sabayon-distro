# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils
DESCRIPTION="A Linux system tray applet that manages EncFS encrypted folders."
HOMEPAGE="http://tom.noflag.org.uk/cryptkeeper.html"

SRC_URI="http://tom.noflag.org.uk/${PN}/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="nls"
DEPEND=">=sys-fs/fuse-2.6.3
	>=sys-fs/encfs-1.5
	>=x11-libs/gtk+-2.12.11:2
	>=gnome-base/gconf-2.22.0
	nls? ( >=sys-devel/gettext-0.14.1 )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"/src
	epatch "${FILESDIR}/${P}-gcc4.4.patch"
}

src_compile() {
	econf $(use_enable nls ) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog TODO
}
