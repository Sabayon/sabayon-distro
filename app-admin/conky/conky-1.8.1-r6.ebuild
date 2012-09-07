# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/conky/conky-1.8.1-r6.ebuild,v 1.8 2012/05/03 18:02:22 jdhore Exp $

EAPI=2

inherit autotools eutils

DESCRIPTION="An advanced, highly configurable system monitor for X"
HOMEPAGE="http://conky.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-3 BSD LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="alpha amd64 ppc ppc64 sparc x86"
IUSE="apcupsd audacious curl debug eve hddtemp imlib iostats lua lua-cairo lua-imlib math moc mpd nano-syntax ncurses nvidia +portmon rss thinkpad truetype vim-syntax weather-metar weather-xoap wifi X xmms2"

DEPEND_COMMON="
	X? (
		imlib? ( media-libs/imlib2 )
		lua-cairo? ( >=dev-lua/toluapp-1.0.93 x11-libs/cairo[X] )
		lua-imlib? ( >=dev-lua/toluapp-1.0.93 media-libs/imlib2 )
		nvidia? ( media-video/nvidia-settings )
		truetype? ( x11-libs/libXft >=media-libs/freetype-2 )
		x11-libs/libX11
		x11-libs/libXdamage
		x11-libs/libXext
		audacious? ( >=media-sound/audacious-1.5 dev-libs/glib )
		xmms2? ( media-sound/xmms2 )
	)
	curl? ( net-misc/curl )
	eve? ( net-misc/curl dev-libs/libxml2 )
	portmon? ( dev-libs/glib )
	lua? ( >=dev-lang/lua-5.1 )
	ncurses? ( sys-libs/ncurses )
	rss? ( dev-libs/libxml2 net-misc/curl dev-libs/glib )
	wifi? ( net-wireless/wireless-tools )
	weather-metar? ( net-misc/curl )
	weather-xoap? ( dev-libs/libxml2 net-misc/curl )
	virtual/libiconv
	"
RDEPEND="
	${DEPEND_COMMON}
	apcupsd? ( sys-power/apcupsd )
	hddtemp? ( app-admin/hddtemp )
	moc? ( media-sound/moc )
	nano-syntax? ( app-editors/nano )
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	"
DEPEND="
	${DEPEND_COMMON}
	virtual/pkgconfig
	"

src_prepare() {
	epatch "${FILESDIR}/${P}-nvidia-x.patch" \
		"${FILESDIR}/${P}-xmms2.patch" \
		"${FILESDIR}/${P}-secunia-SA43225.patch" \
		"${FILESDIR}/${P}-acpitemp.patch" \
		"${FILESDIR}/${P}-curl-headers.patch" \
		"${FILESDIR}/${P}-maxinterfaces.patch" \
		"${FILESDIR}/${P}-utf8-scroll.patch" \
		"${FILESDIR}/${P}-battery-time.patch" \
		"${FILESDIR}/${P}-lua-5.2.patch"
	eautoreconf
}

src_configure() {
	local myconf

	if use X; then
		myconf="--enable-x11 --enable-double-buffer --enable-xdamage"
		myconf="${myconf} --enable-argb --enable-own-window"
		myconf="${myconf} $(use_enable imlib imlib2) $(use_enable lua-cairo)"
		myconf="${myconf} $(use_enable lua-imlib lua-imlib2)"
		myconf="${myconf} $(use_enable nvidia) $(use_enable truetype xft)"
		myconf="${myconf} $(use_enable audacious) $(use_enable xmms2)"
	else
		myconf="--disable-x11 --disable-own-window --disable-argb"
		myconf="${myconf} --disable-lua-cairo --disable-nvidia --disable-xft"
		myconf="${myconf} --disable-audacious --disable-xmms2"
	fi

	econf \
		${myconf} \
		$(use_enable apcupsd) \
		$(use_enable curl) \
		$(use_enable debug) \
		$(use_enable eve) \
		$(use_enable hddtemp) \
		$(use_enable iostats) \
		$(use_enable lua) \
		$(use_enable thinkpad ibm) \
		$(use_enable math) \
		$(use_enable moc) \
		$(use_enable mpd) \
		$(use_enable ncurses) \
		$(use_enable portmon) \
		$(use_enable rss) \
		$(use_enable weather-metar) \
		$(use_enable weather-xoap) \
		$(use_enable wifi wlan)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog AUTHORS TODO || die
	dohtml doc/docs.html doc/config_settings.html doc/variables.html || die

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/ftdetect
		doins "${S}"/extras/vim/ftdetect/conkyrc.vim || die

		insinto /usr/share/vim/vimfiles/syntax
		doins "${S}"/extras/vim/syntax/conkyrc.vim || die
	fi

	if use nano-syntax; then
		insinto /usr/share/nano/
		doins "${S}"/extras/nano/conky.nanorc || die
	fi
}

pkg_postinst() {
	elog "You can find a sample configuration file at ${ROOT%/}/etc/conky/conky.conf."
	elog "To customize, copy it to ~/.conkyrc and edit it to your liking."
	elog
	elog "For more info on Conky's features please look at the Changelog in"
	elog "${ROOT%/}/usr/share/doc/${PF}. There are also pretty html docs available"
	elog "on Conky's site or in ${ROOT%/}/usr/share/doc/${PF}/html."
	elog
	elog "Also see http://www.gentoo.org/doc/en/conky-howto.xml"
	elog
}
