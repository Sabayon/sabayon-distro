# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
PYTHON_DEPEND="2"

inherit eutils flag-o-matic python

MY_P=${P/_beta/BETA}
NM_PN=${PN/zenmap/nmap}
NM_P=${MY_P/zenmap/nmap}

DESCRIPTION="Graphical frontend for nmap"
HOMEPAGE="http://nmap.org/"
SRC_URI="
	http://nmap.org/dist/${NM_P}.tar.bz2
	http://dev.gentoo.org/~jer/nmap-logo-64.png
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="nls"
NMAP_LINGUAS="de es fr hr hu id it ja pl pt_BR pt_PT ro ru sk zh"
for lingua in ${NMAP_LINGUAS}; do
	IUSE+=" linguas_${lingua}"
done

NMAP_PYTHON_DEPEND="
|| (
	dev-lang/python:2.7[sqlite]
	dev-lang/python:2.6[sqlite]
	dev-lang/python:2.5[sqlite]
	dev-python/pysqlite:2
)
"
DEPEND="
	>=x11-libs/gtk+-2.6:2
	>=dev-python/pygtk-2.6
	${NMAP_PYTHON_DEPEND}
"
RDEPEND="
	${DEPEND}
	~net-analyzer/nmap-${PV}
"

S="${WORKDIR}/${NM_P}"

pkg_setup() {
	python_set_active_version 2
}

src_unpack() {
	unpack ${NM_P}.tar.bz2
}

src_prepare() {
	#	"${FILESDIR}"/${PN}-4.75-include.patch
	#	"${FILESDIR}"/${PN}-4.75-nolua.patch
	#	"${FILESDIR}"/${PN}-5.10_beta1-string.patch
	#	"${FILESDIR}"/${PN}-6.01-make.patch
	#	"${FILESDIR}"/${PN}-6.25-lua.patch
	epatch \
		"${FILESDIR}"/${NM_PN}-5.21-python.patch

	mv docs/man-xlate/${NM_PN}-j{p,a}.1 || die
	if use nls; then
		local lingua=''
		for lingua in ${NMAP_LINGUAS}; do
			if ! use linguas_${lingua}; then
				rm -rf zenmap/share/zenmap/locale/${lingua}
				rm -f zenmap/share/zenmap/locale/${lingua}.po
			fi
		done
	else
		# configure/make ignores --disable-nls
		for lingua in ${NMAP_LINGUAS}; do
			rm -rf zenmap/share/zenmap/locale/${lingua}
			rm -f zenmap/share/zenmap/locale/${lingua}.po
		done
	fi

	sed -i \
		-e '/^ALL_LINGUAS =/{s|$| id|g;s|jp|ja|g}' \
		Makefile.in || die

	# Fix desktop files wrt bug #432714
	sed -i \
		-e '/^Encoding/d' \
		-e 's|^Categories=.*|Categories=Network;System;Security;|g' \
		zenmap/install_scripts/unix/zenmap-root.desktop \
		zenmap/install_scripts/unix/zenmap.desktop || die
}

src_configure() {
	# The bundled libdnet is incompatible with the version available in the
	# tree, so we cannot use the system library here.
	# nls disabled for split nmap ebuild - flag used for manipulations above
	econf \
		--with-zenmap \
		--without-liblua \
		--without-ncat \
		--without-ndiff \
		--disable-nls \
		--without-nmap-update \
		--without-nping \
		--without-openssl \
		--with-libdnet=included
}

src_compile() {
	emake build-zenmap || die
}

src_install() {
	emake DESTDIR="${D}" install-zenmap || die
	doicon "${FILESDIR}/nmap-logo-64.png"
}
