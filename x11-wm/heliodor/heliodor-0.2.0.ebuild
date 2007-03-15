# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/heliodor/heliodor-0.1.3.ebuild,v 1.1 2006/12/19 22:11:34 tsunam Exp $

inherit eutils

DESCRIPTION="Beryl Metacity Window Decorator"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc ~ppc64"
IUSE=""
RESTRICT="nomirror"

DEPEND=">=x11-libs/gtk+-2.8.0
	>=x11-libs/libwnck-2.14.2
	>=gnome-base/gconf-2
	>=gnome-base/control-center-2.14
	>=x11-wm/metacity-2.16
	~x11-wm/beryl-core-${PV}"

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

