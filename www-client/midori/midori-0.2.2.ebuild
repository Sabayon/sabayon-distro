# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/midori/midori-0.2.2.ebuild,v 1.2 2009/12/29 18:00:16 armin76 Exp $

EAPI=2
inherit eutils xfconf multilib

DESCRIPTION="A lightweight web browser based on WebKitGTK+"
HOMEPAGE="http://www.twotoasts.de/index.php?/pages/midori_summary.html"
SRC_URI="mirror://xfce/src/apps/${PN}/0.2/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~x86-fbsd"
IUSE="doc gnome html idn libnotify nls +sqlite +unique"

RDEPEND="libnotify? ( x11-libs/libnotify )
	>=net-libs/libsoup-2.25.2
	>=net-libs/webkit-gtk-1.1.1
	dev-libs/libxml2
	>=x11-libs/gtk+-2.10:2
	gnome? ( net-libs/libsoup[gnome] )
	idn? ( net-dns/libidn )
	sqlite? ( >=dev-db/sqlite-3.0 )
	unique? ( dev-libs/libunique )"

DEPEND="${RDEPEND}
	dev-lang/python
	dev-util/pkgconfig
	doc? ( dev-util/gtk-doc )
	html? ( dev-python/docutils )
	nls? ( sys-devel/gettext )"

src_prepare() {
	# moving docs to version-specific directory
	sed -i -e "s:\${DOCDIR}/${PN}:\${DOCDIR}/${PF}/:g" wscript || die
	sed -i -e "s:/${PN}/user/midori.html:/${PF}/user/midori.html:g" midori/midori-browser.c || die

	epatch "${FILESDIR}/${PN}-sabayon-user-agent.patch"
}

src_configure() {
	CCFLAGS="${CFLAGS}" LINKFLAGS="${LDFLAGS}" ./waf \
		--prefix="/usr/" \
		--libdir="/usr/$(get_libdir)" \
		--disable-docs \
		--enable-addons \
		$(use_enable doc apidocs) \
		$(use_enable html userdocs) \
		$(use_enable idn libidn) \
		$(use_enable libnotify) \
		$(use_enable nls nls) \
		$(use_enable sqlite) \
		$(use_enable unique) \
		configure || die "configure failed"
}

src_compile() {
	NUMJOBS=$(sed -e 's/.*\(\-j[ 0-9]\+\) .*/\1/; s/--jobs=\?/-j/' <<< ${MAKEOPTS})
	./waf build ${NUMJOBS} || die "build failed"
}

src_install() {
	DESTDIR=${D} ./waf install || die "install failed"
	dodoc AUTHORS ChangeLog INSTALL TODO || die "dodoc failed"
}

pkg_postinst() {
	xfconf_pkg_postinst
	ewarn "Midori tends to crash due to bugs in WebKit."
	ewarn "Report bugs at http://www.twotoasts.de/bugs"
}
