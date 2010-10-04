# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/amule/amule-2.2.6.ebuild,v 1.1 2009/09/18 14:59:45 patrick Exp $

EAPI="2"

inherit autotools eutils flag-o-matic wxwidgets
MY_PN="amule-adunanza"
MY_PN2="aMule-AdunanzA"
MY_PV="${PV}-2.2.6"
MY_P="${MY_PN2}-${MY_PV}"

S="${WORKDIR}/${MY_P}"

DESCRIPTION="aMule AdunanzA, IL software p2p per la comunita' fastweb"
HOMEPAGE="http://www.adunanza.net/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="daemon debug geoip gtk nls remote stats unicode upnp"

DEPEND="=x11-libs/wxGTK-2.8*
	>=dev-libs/crypto++-5.6.0
	>=sys-libs/zlib-1.2.1
	!net-p2p/amule
	stats? ( >=media-libs/gd-2.0.26[jpeg] )
	geoip? ( dev-libs/geoip )
	upnp? ( >=net-libs/libupnp-1.6.6 )
	remote? ( >=media-libs/libpng-1.2.0
	unicode? ( >=media-libs/gd-2.0.26 ) )"

src_unpack() {
	unpack ${A}
	cd ${S}
        AT_M4DIR="m4" eautoreconf
        elibtoolize              
}                                

pkg_setup() {

	if ! use gtk && ! use remote && ! use daemon; then
		eerror ""
		eerror "You have to specify at least one of gtk, remote or daemon"
		eerror "USE flag to build amule."
		eerror ""
		die "Invalid USE flag set"
	fi

	if use stats && ! use gtk; then
		einfo "Note: You would need both the gtk and stats USE flags"
		einfo "to compile aMule Statistics GUI."
		einfo "I will now compile console versions only."
	fi
}

pkg_preinst() {
	if use daemon || use remote; then
		enewgroup p2p
		enewuser p2p -1 -1 /home/p2p p2p
	fi
}

src_configure() {
	local myconf

	WX_GTK_VER="2.8"

	if use gtk; then
		einfo "wxGTK with gtk support will be used"
		need-wxwidgets unicode
	else
		einfo "wxGTK without X support will be used"
		need-wxwidgets base
	fi

	if use gtk ; then
		use stats && myconf="${myconf}
			--enable-wxcas
			--enable-alc"
		use remote && myconf="${myconf}
			--enable-amule-gui"
	else
		myconf="
			--disable-monolithic
			--disable-amule-gui
			--disable-wxcas
			--disable-alc"
	fi

	# Modify econf to give amuleado a custome name to
	# avoid colliding with the regular version of amule.
	econf \
		--program-suffix=adu \
		--with-wx-config=${WX_CONFIG} \
		--with-wxbase-config=${WX_CONFIG} \
		--enable-amulecmd \
		$(use_enable debug) \
		$(use_enable !debug optimize) \
		$(use_enable daemon amule-daemon) \
		$(use_enable geoip) \
		$(use_enable nls) \
		$(use_enable remote webserver) \
		$(use_enable stats cas) \
		$(use_enable stats alcc) \
		${myconf} || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	if use daemon; then
		newconfd "${FILESDIR}"/amuled.confd amuled
		newinitd "${FILESDIR}"/amuled.initd amuled
	fi
	if use remote; then
		newconfd "${FILESDIR}"/amuleweb.confd amuleweb
		newinitd "${FILESDIR}"/amuleweb.initd amuleweb
	fi
}

pkg_postinst() {
	ewarn "Per maggiori informazioni sullo sviluppo di aMule AdunanzA"
	ewarn "e per richieste di supporto potete consultare il forum della"
	ewarn "comunita': http://forum.adunanza.net"
}
