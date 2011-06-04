# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils flag-o-matic

DESCRIPTION="Gtk+-based Yahoo! chat client"
HOMEPAGE="http://gyachi.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa blowfish gpgme gtkspell libnotify mcrypt pulseaudio +voice"

DEPEND="
	dev-libs/openssl
	dev-libs/libxml2
	media-libs/jasper
	gnome-extra/gtkhtml:2
	x11-libs/gtk+:2
	alsa? ( media-libs/alsa-lib )
	gpgme? ( app-crypt/gpgme )
	gtkspell? ( app-text/gtkspell )
	libnotify? ( >=x11-libs/libnotify-0.7 )
	mcrypt? ( dev-libs/libmcrypt )
	pulseaudio? ( media-sound/pulseaudio )
"
RDEPEND="${DEPEND}
	www-client/htmlview"

src_prepare() {
	epatch "${FILESDIR}/${PN}-gpgme-gentoo.patch"
	epatch "${FILESDIR}/${PN}-pthread_yield-obsolete.patch"
	use libnotify && epatch "${FILESDIR}/${PN}-libnotify-build-broken.patch"
	sed -i "s/Icon=gyachi\.png/Icon=gyach-icon_48/" gyachi.desktop \
		|| die "sed failed"
}

src_configure() {
	use gpgme && append-lfs-flags

	# local myconf="--disable-plugin-xmms --enable-plugin_photo_album --enable-wine"
	local myconf="--disable-plugin-xmms --enable-plugin_photo_album"
	# appears to be broken: --enable-plugin_esd
	local plugin
	for plugin in alsa gpgme libnotify mcrypt pulseaudio blowfish; do
		if use ${plugin}; then
			myconf="${myconf} --enable-plugin_${plugin}"
		else
			myconf="${myconf} --disable-plugin_${plugin}"
		fi
	done
	myconf="${myconf} $(use_enable gtkspell)"
	myconf="${myconf} $(use_enable voice wine)"

	einfo "Running provided autogen.sh script..."
	./autogen.sh || die
	econf $myconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	doicon "${S}"/themes/gyachi-classic/gyach-icon_48.png || die
}
