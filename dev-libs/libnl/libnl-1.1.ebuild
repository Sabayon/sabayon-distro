# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libnl/libnl-1.0_pre6-r1.ebuild,v 1.1 2007/12/01 19:47:49 rbu Exp $

inherit eutils multilib linux-info versionator

MY_P="${PN}-${PV/_/-}"

DESCRIPTION="A library for applications dealing with netlink socket"
HOMEPAGE="http://people.suug.ch/~tgr/libnl/"
SRC_URI="http://people.suug.ch/~tgr/libnl/files/${MY_P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~x86"
IUSE=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}/lib"
	sed -i Makefile -e 's:install -o root -g root:install:'

	cd "${S}/include"
	sed -i Makefile -e 's:install -o root -g root:install:g'
	epatch "${FILESDIR}/${PN}-1.0_pre5-include.diff"
	epatch "${FILESDIR}/${P}-types.patch"
	
}

src_install() {
	emake DESTDIR="${D}" install || die
}
