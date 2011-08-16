# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="GMapCatcher is an offline maps viewer. It downloads tiles automatically from many providers."
HOMEPAGE="http://code.google.com/p/gmapcatcher/"
SRC_URI="http://gmapcatcher.googlecode.com/files/GMapCatcher-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
RESTRICT="mirror"
IUSE=""

DEPEND="dev-lang/python:2.6
	x11-libs/gtk+
	dev-python/pygtk
	dev-python/pygobject
	dev-python/pycairo
	dev-python/imaging"
RDEPEND="${DEPEND}"


src_install() {

	base=GMapCatcher-${PV}


	domenu ${base}/gmapcatcher.desktop
	newicon ${base}/images/map.png mapcatcher.png
	doman ${base}/man/*
	dodoc ${base}/README

	insinto /usr/share/${PF}/
	doins -r ${base}/gmapcatcher || die
	
	exeinto /usr/share/${PF}/
	doexe    ${base}/maps.py || die
	doexe    ${base}/download.py || die

	dosym ../share/${PF}/maps.py /usr/bin/mapcatcher
	dosym ../share/${PF}/download.py /usr/bin/mapdownloader
}
