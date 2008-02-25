# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/wireshark/wireshark-0.99.8_rc1.ebuild,v 1.2 2008/02/21 20:44:13 pva Exp $

WANT_AUTOMAKE="1.9"
inherit autotools libtool flag-o-matic eutils toolchain-funcs

DESCRIPTION="A network protocol analyzer formerly known as ethereal"
HOMEPAGE="http://www.wireshark.org/"

# _rc versions has different download location.
[[ -n ${PV#*_rc} && ${PV#*_rc} != ${PV} ]] && {
SRC_URI="http://www.wireshark.org/download/prerelease/${PN}-${PV/_rc/pre}.tar.gz";
S=${WORKDIR}/${PN}-${PV/_rc/pre} ; } || \
SRC_URI="http://www.wireshark.org/download/src/all-versions/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="adns gtk ipv6 lua portaudio snmp ssl kerberos threads selinux"

RDEPEND="sys-libs/zlib
	snmp? ( net-analyzer/net-snmp )
	gtk? ( >=dev-libs/glib-2.0.4
		=x11-libs/gtk+-2*
		x11-libs/pango
		dev-libs/atk )
	!gtk? ( =dev-libs/glib-1.2* )
	ssl? ( dev-libs/openssl )
	!ssl? (	net-libs/gnutls )
	net-libs/libpcap
	dev-libs/libpcre
	sys-libs/libcap
	adns? ( net-libs/adns )
	kerberos? ( virtual/krb5 )
	portaudio? ( media-libs/portaudio )
	lua? ( >=dev-lang/lua-5.1 )
	selinux? ( sec-policy/selinux-wireshark )
	net-libs/libsmi
	"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.15.0
	dev-lang/perl
	sys-devel/bison
	sys-devel/flex
	sys-apps/sed"

pkg_setup() {
	# bug 119208
	if has_version "<=dev-lang/perl-5.8.8_rc1" && built_with_use dev-lang/perl minimal ; then
		ewarn "wireshark will not build if dev-lang/perl is compiled with"
		ewarn "USE=minimal. Rebuild dev-lang/perl with USE=-minimal and try again."
		ebeep 5
		die "dev-lang/perl compiled with USE=minimal"
	fi

	if ! use gtk; then
		ewarn "USE=-gtk will mean no gui called wireshark will be created and"
		ewarn "only command line utils are available"
	fi

	# Add group for users allowed to sniff.
	enewgroup wireshark || die "Failed to create wireshark group"
}

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.99.7-asneeded.patch
	epatch "${FILESDIR}"/${PN}-0.99.8-as-needed.patch

	cd "${S}"/epan
	epatch "${FILESDIR}"/wireshark-except-double-free.diff

	cd "${S}"
	AT_M4DIR="${S}/aclocal-fallback"
	eautoreconf
}

src_compile() {
	# optimization bug, see bug #165340, bug #40660
	if [[ $(gcc-version) == 3.4 ]] ; then
		elog "Found gcc 3.4, forcing -O3 into CFLAGS"
		replace-flags -O? -O3
	elif [[ $(gcc-version) == 3.3 || $(gcc-version) == 3.2 ]] ; then
		elog "Found <=gcc-3.3, forcing -O into CFLAGS"
		replace-flags -O? -O
	fi

	# see bug #133092
	filter-flags -fstack-protector

	local myconf

	if use gtk; then
		einfo "Building with gtk support"
	else
		einfo "Building without gtk support"
		myconf="${myconf} --disable-wireshark --disable-warnings-as-errors"
		# the asn1 plugin needs gtk
		sed -i -e '/plugins.asn1/d' Makefile.in || die "sed failed"
		sed -i -e '/^SUBDIRS/s/asn1//' plugins/Makefile.in || die "sed failed"
	fi

	econf $(use_with ssl) \
		$(use_enable ipv6) \
		$(use_with lua) \
		$(use_with adns) \
		$(use_with kerberos krb5) \
		$(use_with snmp net-snmp) \
		$(use_with portaudio) \
		$(use_enable gtk gtk2) \
		$(use_enable threads) \
		--with-libcap \
		--enable-setuid-install \
		--without-ucd-snmp \
		--enable-dftest \
		--enable-randpkt \
		--sysconfdir=/etc/wireshark \
		--enable-editcap \
		--enable-capinfos \
		--enable-text2pcap \
		${myconf} || die "econf failed"

	# fixes an access violation caused by libnetsnmp - see bug 79068
	use snmp && export MIBDIRS="${D}/usr/share/snmp/mibs"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	for file in /usr/bin/tshark /usr/bin/dumpcap
	do
		fowners 0:wireshark ${file}
		fperms 6550 ${file}
	done

	insinto /usr/include/wiretap
	doins wiretap/wtap.h

	dodoc AUTHORS ChangeLog NEWS README*

	if use gtk ; then
		insinto /usr/share/icons/hicolor/16x16/apps
		newins image/hi16-app-wireshark.png wireshark.png
		insinto /usr/share/icons/hicolor/32x32/apps
		newins image/hi32-app-wireshark.png wireshark.png
		insinto /usr/share/icons/hicolor/48x48/apps
		newins image/hi48-app-wireshark.png wireshark.png
		insinto /usr/share/applications
		doins wireshark.desktop
	fi
}

pkg_postinst() {
	echo
	ewarn "With version 0.99.7, all function calls that require elevated privileges"
	ewarn "have been moved out of the GUI to dumpcap. WIRESHARK CONTAINS OVER ONE"
	ewarn "POINT FIVE MILLION LINES OF SOURCE CODE. DO NOT RUN THEM AS ROOT."
	ewarn
	ewarn "NOTE: To run wireshark as normal user you have to add yourself into"
	ewarn "wireshark group. This security measure ensures that only trusted"
	ewarn "users allowed to sniff your traffic."
	echo
}
