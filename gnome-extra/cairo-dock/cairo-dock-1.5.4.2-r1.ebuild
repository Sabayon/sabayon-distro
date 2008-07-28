# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest
EAPI=1

inherit autotools eutils

# Upstream sources use date instead version number
MY_PV="20080408"

DESCRIPTION="Cairo-dock is yet another dock applet"
HOMEPAGE="http://developer.berlios.de/projects/cairo-dock/"
SRC_URI="http://download2.berlios.de/cairo-dock/cairo-dock-sources-${MY_PV}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

S="${WORKDIR}/opt/${PN}/trunk"

IUSE="themes glitz doc kde gnome xfce compiz-fusion"

DEPEND="
	glitz? ( >=media-libs/glitz-0.5.6 )
	gnome-base/librsvg
	sys-apps/dbus
	dev-libs/dbus-glib
	x11-libs/libXcomposite
	>=dev-libs/glib-2.14.6
	dev-libs/libxml2
	x11-libs/cairo
	kde?	( || ( kde-base/kwin kde-base/kwin:kde-4 ) )
	gnome?	( x11-misc/xcompmgr )
	xfce?	( xfce-base/xfwm4   )
	compiz-fusion?	( || ( x11-wm/compiz-fusion x11-wm/compiz-fusion-git ) )"

PDEPEND=">=x11-plugins/cairo-dock-plugins-${PV}
	themes? ( >=x11-themes/cairo-dock-themes-${PV} )"

src_unpack() {
	if ! use glitz; then
		einfo "Enabling the glitz USE flag is recommended."
		einfo "It will improve the performance of cairo-dock."
	fi
	unpack cairo-dock-sources-${MY_PV}.tar.bz2
	cd "${S}/${PN}"
	eautoreconf || die "eautoreconf failed at cairo-dock"
	econf || die "econf failed at cairo-dock"
}

src_compile() {
	cd "${S}/cairo-dock"
	emake || die "emake failed at cairo-dock"
}

src_install() {
	cd "${S}/cairo-dock"
	emake DESTDIR="${D}" install || die "emake install failed at cairo-dock"
	if use doc; then
		dodoc ANNOUNCE AUTHORS ChangeLog NEWS README* TODO
	fi
}
