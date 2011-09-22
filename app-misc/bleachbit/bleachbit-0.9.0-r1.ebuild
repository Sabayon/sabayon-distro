# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils distutils

DESCRIPTION="Free disk space and maintain privacy"
HOMEPAGE="http://bleachbit.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

RDEPEND="dev-python/pygtk
	dev-python/simplejson
	dev-lang/python[sqlite,xml]"
DEPEND="sys-devel/gettext
	${RDEPEND}"

src_prepare() {
	# /usr/lib/python2.7/site-packages/bleachbit/Unix.py:45: ImportWarning: Not
	# importing directory '/usr/share/gnome': missing __init__.py
	epatch "${FILESDIR}"/${P}-no-append-path.patch
	distutils_src_prepare
}

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

	newbin ${PN}.py ${PN} || die
	doicon ${PN}.png || die

	insinto /usr/share/applications
	doins ${PN}.desktop || die

	insinto /usr/share/${PN}
	doins -r cleaners || die

	if use nls ; then
	    cd "${S}/po"
	    emake DESTDIR="${D}" install || die "translation install failed"
	fi
}
