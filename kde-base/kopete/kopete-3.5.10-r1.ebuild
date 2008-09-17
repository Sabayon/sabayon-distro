# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kopete/kopete-3.5.10.ebuild,v 1.1 2008/09/13 23:59:21 carlo Exp $

KMNAME=kdenetwork
EAPI="1"
inherit kde-meta eutils

DESCRIPTION="KDE multi-protocol IM client"
HOMEPAGE="http://kopete.kde.org/"

KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="jingle sametime ssl xscreensaver slp kernel_linux latex crypt
		winpopup sms irc yahoo gadu groupwise netmeeting statistics autoreplace
		connectionstatus contactnotes translator webpresence texteffect highlight
		alias autoreplace history nowlistening addbookmarks kdehiddenvisibility"

# Even more broken tests...
RESTRICT="test"

# The kernel_linux? ( ) conditional dependencies are for webcams, not supported
# on other kernels AFAIK
BOTH_DEPEND="dev-libs/libxslt
	dev-libs/libxml2
	net-dns/libidn
	>=dev-libs/glib-2
	=app-crypt/qca-1.0*
	sametime? ( =net-libs/meanwhile-1.0* )
	jingle? (
		>=media-libs/speex-1.1.6
		dev-libs/expat
		~net-libs/ortp-0.7.1 )
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
	xscreensaver? ( x11-libs/libXScrnSaver )
	kernel_linux? ( virtual/opengl )
	sms? ( app-mobilephone/gsmlib )"

RDEPEND="${BOTH_DEPEND}
	ssl? ( =app-crypt/qca-tls-1.0* )
	latex? ( virtual/latex-base
		media-gfx/imagemagick )
	crypt? ( app-crypt/gnupg )"

#	!kde-base/kdenetwork is handled by the eclass.
#	gnomemeeting is deprecated and ekiga is not yet ~ppc64
#	only needed for calling
#	netmeeting? ( net-im/gnomemeeting )"

DEPEND="${BOTH_DEPEND}
	kernel_linux? ( virtual/os-headers )
	x11-proto/videoproto
	kernel_linux? ( x11-libs/libXv )
	xscreensaver? ( x11-proto/scrnsaverproto )"

pkg_setup() {
	if use kernel_linux && ! built_with_use x11-libs/qt:3 opengl; then
		eerror "To support Video4Linux webcams in this package is required to have"
		eerror "x11-libs/qt:3 compiled with OpenGL support."
		eerror "Please reemerge x11-libs/qt:3 with USE=\"opengl\"."
		die "Please reemerge x11-libs/qt:3 with USE=\"opengl\"."
	fi
}

kopete_disable() {
	einfo "Disabling $2 $1"
	sed -i -e "s/$2//" "${S}/kopete/$1s/Makefile.am"
}

src_unpack() {
	kde-meta_src_unpack

	epatch "${FILESDIR}/kopete-0.12_alpha1-xscreensaver.patch"
	epatch "${FILESDIR}/kopete-3.5.5-icqfix.patch"
	epatch "${FILESDIR}/kdenetwork-3.5.5-linux-headers-2.6.18.patch"
	epatch "${FILESDIR}/${P}-gcc4.3.patch"

	use latex || kopete_disable plugin latex
	use crypt || kopete_disable plugin cryptography
	use netmeeting || kopete_disable plugin netmeeting
	use statistics || kopete_disable plugin statistics
	use autoreplace || kopete_disable plugin autoreplace
	use connectionstatus || kopete_disable plugin connectionstatus
	use contactnotes || kopete_disable plugin contactnotes
	use translator || kopete_disable plugin translator
	use webpresence || kopete_disable plugin webpresence
	use texteffect || kopete_disable plugin texteffect
	use highlight || kopete_disable plugin highlight
	use alias || kopete_disable plugin alias
	use addbookmarks || kopete_disable plugin addbookmarks
	use history || kopete_disable plugin history
	use nowlistening || kopete_disable plugin nowlistening

	use winpopup || kopete_disable protocol winpopup
	use gadu || kopete_disable protocol '\$(GADU)'
	use irc || kopete_disable protocol irc
	use groupwise || kopete_disable protocol groupwise
	use yahoo || kopete_disable protocol yahoo

	rm -f "${S}/configure"
}

src_compile() {
	# External libgadu support - doesn't work, kopete requires a specific development snapshot of libgadu.
	# Maybe we can enable it in the future.
	local myconf="$(use_enable jingle)
		$(use_enable sametime sametime-plugin)
		--without-xmms --without-external-libgadu
		$(use_with xscreensaver) $(use_enable sms smsgsm)
		$(use_enable debug testbed)"

	kde_src_compile
}

src_install() {
	kde_src_install

	rm -f "${D}${KDEDIR}"/bin/{stun,relay}server
}

pkg_postinst() {
	kde_pkg_postinst

	elog "If you would like to use Off-The-Record encryption, emerge net-im/kopete-otr."
}
