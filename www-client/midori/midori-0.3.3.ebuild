# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/midori/midori-0.3.2.ebuild,v 1.1 2011/02/26 21:24:14 angelos Exp $

EAPI=3
inherit eutils multilib python xfconf waf-utils

DESCRIPTION="A lightweight web browser based on WebKitGTK+"
HOMEPAGE="http://www.twotoasts.de/index.php?/pages/midori_summary.html"
SRC_URI="mirror://xfce/src/apps/${PN}/0.3/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~x86-fbsd"
IUSE="doc gnome +html idn libnotify nls +unique"

RDEPEND="libnotify? ( x11-libs/libnotify )
	>=net-libs/libsoup-2.25.2
	>=net-libs/webkit-gtk-1.1.1
	>=dev-db/sqlite-3.0
	dev-libs/libxml2
	>=x11-libs/gtk+-2.10:2
	gnome? ( net-libs/libsoup-gnome )
	idn? ( net-dns/libidn )
	unique? ( dev-libs/libunique )"
DEPEND="${RDEPEND}
	|| ( dev-lang/python:2.7 dev-lang/python:2.6 )
	dev-util/intltool
	dev-util/pkgconfig
	doc? ( dev-util/gtk-doc )
	html? ( dev-python/docutils )
	nls? ( sys-devel/gettext )"

pkg_setup() {
	python_set_active_version 2
	DOCS="AUTHORS ChangeLog INSTALL TODO"
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-sabayon-user-agent.patch"
	epatch "${FILESDIR}/${PN}-advertise-proper-arch-in-user-agent.patch"
}

src_configure() {
	strip-linguas -i po

	waf-utils_src_configure \
		--docdir="/usr/share/doc/${PF}/html" \
		--disable-docs \
		--enable-addons \
		$(use_enable doc apidocs) \
		$(use_enable html userdocs) \
		$(use_enable idn libidn) \
		$(use_enable libnotify) \
		$(use_enable nls) \
		$(use_enable unique) \
		--disable-vala
}
