# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
PYTHON_DEPEND="2"

inherit eutils flag-o-matic python

MY_P=${P/_beta/BETA}

DESCRIPTION="Graphical frontend for nmap"
HOMEPAGE="http://nmap.org/"
SRC_URI="http://nmap.org/dist/${MY_P/zenmap/nmap}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.6:2
		>=dev-python/pygtk-2.6
		|| ( dev-lang/python:2.7[sqlite] dev-lang/python:2.6[sqlite] dev-lang/python:2.5[sqlite] dev-python/pysqlite:2 )
		"
RDEPEND="${DEPEND}
		~net-analyzer/nmap-${PV}"

S="${WORKDIR}/${MY_P/zenmap/nmap}"

pkg_setup() {
	python_set_active_version 2
}

src_prepare() {
	# epatch "${FILESDIR}"/${PN}-4.75-include.patch
	# epatch "${FILESDIR}"/${PN}-4.75-nolua.patch
	# epatch "${FILESDIR}"/${PN}-5.10_beta1-string.patch
	epatch "${FILESDIR}"/${PN/zenmap/nmap}-5.21-python.patch
	sed -i -e 's/-m 755 -s ncat/-m 755 ncat/' ncat/Makefile.in

	## bug #416987
	#epatch "${FILESDIR}"/${P}-make.patch
}

src_configure() {
	# The bundled libdnet is incompatible with the version available in the
	# tree, so we cannot use the system library here.
	econf --with-libdnet=included \
		--with-zenmap \
		--without-ncat \
		--without-ndiff \
		--without-nmap-update \
		--without-nping \
		--without-ndiff \
		|| die "configure failed!"
}

src_compile() {
	emake build-zenmap || die
}

src_install() {
	emake DESTDIR="${D}" install-zenmap || die
	doicon "${FILESDIR}/nmap-logo-64.png"
}
