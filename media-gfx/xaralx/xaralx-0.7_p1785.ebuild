# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

WX_GTK_VER="2.8"

inherit eutils wxwidgets autotools gnome2

MY_P=XaraLX-${PV/_p/r}

DESCRIPTION="General purpose vector graphics program"
HOMEPAGE="http://www.xaraxtreme.org/"
SRC_URI="
	http://downloads.xara.com/opensource/${MY_P}.tar.bz2
	http://dev.gentoo.org/~jlec/distfiles/60_launchpad_translations.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	x11-libs/gtk+:2
	x11-libs/wxGTK:2.8[X]
	virtual/libintl
	media-libs/libpng
	virtual/jpeg
	app-arch/zip
	dev-lang/perl
	dev-libs/libxml2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/gettext-0.14.3"

S=${WORKDIR}/${MY_P/Src/}

src_prepare() {
	epatch \
		"${WORKDIR}"/60_launchpad_translations \
		"${FILESDIR}"/${P}-pragma.patch \
		"${FILESDIR}"/{3,4,5}0*
	sed -i -e "s/CXFTreeDlg:://" Kernel/cxftree.h
	sed -i -e "s:XaraLX:xaralx:g" Makefile.am
	sed -i '/info_ptr->trans/s:trans:trans_alpha:' wxOil/outptpng.cpp
	AT_M4DIR=". ${S}/m4" eautoreconf
}

src_configure() {
	econf \
		--with-wx-config=${WX_CONFIG} \
		--with-wx-base-config=${WX_CONFIG} \
		--enable-xarlib \
		--enable-filters
}

src_install() {
	default

	dodoc doc/{gifutil.txt,mtrand.txt,XSVG.txt}

	insinto /usr/share/${PN}
	doins -r Designs Templates

	doicon ${PN}.png
	domenu ${PN}.desktop

	insinto /usr/share/icons/hicolor/48x48/mimetypes
	newins xaralx.png gnome-mime-application-vnd.xara.png
	insinto /usr/share/mime/packages
	doins Mime/xaralx.xml
	insinto /usr/share/application-registry
	doins Mime/mime-storage/gnome/xaralx.applications
	insinto /usr/share/mime-info
	doins Mime/mime-storage/gnome/xaralx.{keys,mime}

	doman doc/xaralx.1
	newdoc doc/en/LICENSE LICENSE-docs
	dodir /usr/share/doc/${PF}/html
	tar xzf doc/en/xaralxHelp.tar.gz -C "${D}"/usr/share/doc/${PF}/html
}
