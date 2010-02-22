# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/abiword-plugins/abiword-plugins-2.6.8.ebuild,v 1.3 2009/07/29 22:51:02 dirtyepic Exp $

EAPI=2

inherit eutils

DESCRIPTION="Set of plugins for abiword"
HOMEPAGE="http://www.abisource.com/"
SRC_URI="http://www.abisource.com/downloads/abiword/${PV}/source/${P}.tar.gz
	http://www.abisource.com/downloads/abiword/${PV}/source/${P//-plugins/}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="cxx debug gnome grammar jabber jpeg libgda math ots pdf readline svg thesaurus wmf wordperfect"

# FIXME: add asio support (better wait on boost 1.35)
# add abiscan when we get gnome-scan

RDEPEND="=app-office/abiword-${PV}*
	>=media-libs/fontconfig-1
	>=dev-libs/fribidi-0.10.4
	>=dev-libs/glib-2
	>=x11-libs/gtk+-2
	x11-libs/libXft
	>=gnome-base/libglade-2
	>=gnome-extra/libgsf-1.14.4
	cxx? ( >=dev-libs/boost-1.33.1 )
	gnome? ( >=x11-libs/goffice-0.4:0.4[gnome] )
	grammar? ( >=dev-libs/link-grammar-4.2.2 )
	!alpha? ( !ia64? ( jabber? (
		>=dev-libs/libxml2-2.4
		>=net-libs/loudmouth-1.0.1 ) ) )
	jpeg?  ( >=media-libs/jpeg-6b-r2 )
	libgda? (
		=gnome-extra/libgda-1*
		=gnome-extra/libgnomedb-1* )
	math? ( >=x11-libs/gtkmathview-0.7.5 )
	!ia64? ( !ppc64? ( !sparc? ( ots? ( >=app-text/ots-0.5 ) ) ) )
	pdf? ( >=virtual/poppler-utils-0.5.0-r1[abiword] )
	readline? ( sys-libs/readline )
	thesaurus? ( >=app-text/aiksaurus-1.2 )
	wordperfect? ( >=app-text/libwpd-0.8 )
	wmf? ( >=media-libs/libwmf-0.2.8 )
	svg? ( >=gnome-base/librsvg-2 )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9"

pkg_setup() {
	if use jabber && ! use cxx; then
		eerror "AbiCollab needs dev-libs/boost to be build"
		die "Add USE=\"cxx\" to build AbiCollab plugin"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-glibc-2.10.patch
	epatch "${FILESDIR}"/${P}-glibc-2.10+api.patch
}

src_configure(){
	local myconf="--enable-all \
		--with-abiword="${WORKDIR}/abiword-${PV}" \
		$(use_with cxx boost) \
		$(use_with cxx OpenXML) \
		$(use_enable debug) \
		$(use_with gnome abigoffice) \
		$(use_with grammar abigrammar) \
		$(use_with jabber abicollab) \
		$(use_with jpeg) \
		$(use_with libgda gda) \
		$(use_with math abimathview) \
		$(use_with ots) \
		$(use_with pdf) \
		$(use_with readline abicommand)
		$(use_with svg librsvg) \
		$(use_with thesaurus aiksaurus) \
		$(use_with wmf) \
		$(use_with wordperfect wpg) \
		--disable-abiscan \
		--without-psion"

	econf ${myconf}
}

src_compile() {
	emake || die "Compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog README || die "dodoc failed"
}
