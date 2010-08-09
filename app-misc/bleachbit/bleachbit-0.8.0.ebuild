# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

DESCRIPTION="Free disk space and maintain privacy"
HOMEPAGE="http://bleachbit.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="dev-python/pygtk"
DEPEND="sys-devel/gettext
	${RDEPEND}"

src_compile() {
	distutils_src_compile

	if use nls ;
	then
	    cd "${S}/po"
	    emake || die "make translations failed"
	fi
}

src_install() {
	distutils_src_install

	newbin ${PN}.py ${PN}
	doicon ${PN}.png

	insinto /usr/share/applications
	doins ${PN}.desktop

	insinto /usr/share/data/${PN}
	doins -r cleaners

	if use nls ; then
	    cd "${S}/po"
	    emake DESTDIR="${D}" install || die "translation install failed"
	fi
}
