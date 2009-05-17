# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-session/gnome-session-2.26.1.ebuild,v 1.2 2009/05/14 05:39:31 nirbheek Exp $

EAPI="2"

inherit eutils fdo-mime gnome2

DESCRIPTION="Gnome session manager"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${SRC_URI}
	mirror://gentoo/${P}-gentoo-patches.tar.bz2
	branding? ( mirror://gentoo/gentoo-splash.png )"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

IUSE="branding doc ipv6 policykit"

RDEPEND=">=dev-libs/glib-2.16
	>=x11-libs/gtk+-2.11.1
	>=gnome-base/libglade-2.3.6
	>=dev-libs/dbus-glib-0.76
	>=gnome-base/gconf-2
	>=x11-libs/startup-notification-0.9
	policykit? ( >=gnome-extra/policykit-gnome-0.7 )

	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXtst
	x11-apps/xdpyinfo"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	>=sys-devel/gettext-0.10.40
	>=dev-util/pkgconfig-0.17
	>=dev-util/intltool-0.40
	!<gnome-base/gdm-2.20.4
	doc? (
		app-text/xmlto
		dev-libs/libxslt )"
# gnome-base/gdm does not provide gnome.desktop anymore

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	# TODO: convert libnotify to a configure option
	G2CONF="${G2CONF}
		$(use_enable doc docbook-docs)
		$(use_enable ipv6)
		$(use_enable policykit polkit)"
}

src_prepare() {
	gnome2_src_prepare

	# Patch for Gentoo Branding (bug #42687)
	use branding && epatch "${FILESDIR}/${PN}-2.17.90.1-gentoo-branding.patch"

	# Fix shutdown/restart capability, upstream bug #549150
	epatch "${WORKDIR}/${PN}-2.26.1-shutdown.patch"

	# Add "session saving" button back, upstream bug #575544
	epatch "${WORKDIR}/${PN}-2.26.1-session-saving-button.patch"
}

src_install() {
	gnome2_src_install

	dodir /etc/X11/Sessions
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}/Gnome" || die "doexe failed"

	# Our own splash for world domination
	if use branding ; then
		insinto /usr/share/pixmaps/splash/
		doins "${DISTDIR}/gentoo-splash.png" || die "doins failed"
	fi
}

pkg_postinst() {
        fdo-mime_mime_database_update
        fdo-mime_desktop_database_update
        gnome2_gconf_savelist
        gnome2_gconf_install
        if [[ "${SCROLLKEEPER_UPDATE}" = "1" ]]; then
                gnome2_scrollkeeper_update
        fi
}
