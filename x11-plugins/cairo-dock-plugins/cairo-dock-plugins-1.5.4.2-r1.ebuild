# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest
inherit autotools eutils

# Upstream sources use date instead version number
MY_PV="20080408"

DESCRIPTION="Cairo-dock is yet another dock applet."
HOMEPAGE="http://developer.berlios.de/projects/cairo-dock/"
SRC_URI="http://download2.berlios.de/cairo-dock/cairo-dock-sources-${MY_PV}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

MYPLUGINS="penguin dbus xgamma alsa-mixer clock compiz-icon dustbin gnome-integration gnome-integration-old logout mail netspeed powermanager rame rendering rhythmbox shortcuts show-desklets show-desktop slider stacks switcher systray terminal tomboy weather wifi xfce-integration xmms"

IUSE=${MYPLUGINS}

DEPEND="gnome-extra/cairo-dock
	dev-libs/glib
	dev-libs/libxml2
	dbus? ( sys-apps/dbus dev-libs/dbus-glib )
	Xgamma? ( x11-libs/libXxf86vm )
	alsa? ( media-sound/alsa-headers )
	gnome? ( >=gnome-base/gnome-vfs-2.0
                                >=gnome-base/libgnomeui-2.0 )
	gnome-integration-old? ( >=gnome-base/gnome-vfs-2.0
                                >=gnome-base/libgnomeui-2.0 )
	mail?	( net-libs/gnutls )
	powermanager? ( sys-apps/dbus dev-libs/dbus-glib )
	rhythmbox? ( sys-apps/dbus dev-libs/dbus-glib )
	tomboy?	( sys-apps/dbus dev-libs/dbus-glib )
	weblets? ( || ( www-client/mozilla-firefox www-client/seamonkey ) )
	xfce? ( xfce-base/xfwm4 xfce-base/thunar )"

RDEPEND=${DEPEND}


S="${WORKDIR}/opt/cairo-dock/trunk/plug-ins"

src_unpack() {
	unpack cairo-dock-sources-${MY_PV}.tar.bz2
	cd "${S}"
	#the source tree seems to have issues, let's fix it:
	sed s/\-fgnu89\-inline// <mail/src/Makefile.am >tmp.am
	mv tmp.am mail/src/Makefile.am
	#cp rame/po/Makefile.in.in slider/po/Makefile.in.in
	
	# Rename folders to match more 'canonical' use flag names (dbus, gnome, xfce are the main reasons).
	# Renaming folders avoid use another list to map real folder to declared use flag
	mv Dbus dbus
	mv gnome-integration gnome
	mv xfce-integration xfce
	
	mv alsaMixer alsa
	mv Cairo-Penguin penguin
	mv Xgamma xgamma
	mv showDesklets show-desklets
	mv showDesktop show-desktop
	
	for plugin in ${MYPLUGINS}; do
		if use ${plugin}; then
			cd "${S}/${plugin}"
			eautoreconf || die "eautoreconf failed on ${plugin}"
			econf || die "econf failed on ${plugin}"
		fi
	done
}

src_compile() {
	for plugin in ${MYPLUGINS}; do
		if use ${plugin}; then
			cd "${S}/${plugin}"
			make || die "emake failed on ${plugin}"
#			emake || die "emake failed on ${plugin}"
		fi
	done
}

src_install() {
	for plugin in ${MYPLUGINS}; do
		if use ${plugin}; then
			cd "${S}/${plugin}"
			emake DESTDIR="${D}" install || die "emake install failed on ${plugin}"
		fi
	done
}
