# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdelibs/kdelibs-3.5.5-r5.ebuild,v 1.1 2006/10/25 20:29:22 flameeyes Exp $

inherit kde flag-o-matic eutils multilib
set-kdedir 3.5

DESCRIPTION="KDE libraries needed by all KDE programs."
HOMEPAGE="http://www.kde.org/"
SRC_URI="mirror://kde/stable/${PV}/src/${P}.tar.bz2
	mirror://gentoo/${P}-seli-xinerama.patch.bz2
	mirror://gentoo/kdelibs-3.5-patchset-05.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="3.5"
KEYWORDS="~alpha ~ppc ~x86 ~amd64"
IUSE="acl alsa arts cups doc jpeg2k kerberos legacyssl utempter openexr pertty spell ssl tiff
zeroconf kernel_linux fam lua linguas_he kdehiddenvisibility"

# kde.eclass has kdelibs in DEPEND, and we can't have that in here.
# so we recreate the entire DEPEND from scratch.

# Added aspell-en as dependency to work around bug 131512.
RDEPEND="$(qt_min_version 3.3.3)
	arts? ( ~kde-base/arts-${PV} )
	app-arch/bzip2
	>=media-libs/freetype-2
	media-libs/fontconfig
	>=dev-libs/libxslt-1.1.16
	>=dev-libs/libxml2-2.6.6
	>=dev-libs/libpcre-4.2
	media-libs/libart_lgpl
	net-dns/libidn
	acl? ( kernel_linux? ( sys-apps/acl ) )
	ssl? ( >=dev-libs/openssl-0.9.7d )
	alsa? ( media-libs/alsa-lib )
	cups? ( >=net-print/cups-1.1.19 )
	tiff? ( media-libs/tiff )
	kerberos? ( virtual/krb5 )
	jpeg2k? ( media-libs/jasper )
	openexr? ( >=media-libs/openexr-1.2.2-r2 )
	zeroconf? (     !avahi? ( net-misc/mDNSResponder !kde-misc/kdnssd-avahi ) )
	fam? ( virtual/fam )
	virtual/ghostscript
	utempter? ( sys-libs/libutempter )
	!kde-base/kde-env
	lua? ( dev-lang/lua )
	spell? ( app-text/aspell app-dicts/aspell-en
		linguas_he? ( >=app-text/hspell-1.0 ) )"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	sys-devel/gettext"

RDEPEND="${RDEPEND}
	|| ( ( x11-apps/rgb x11-apps/iceauth ) <virtual/x11-7 ) "

PDEPEND="zeroconf? ( avahi? ( kde-misc/kdnssd-avahi ) )"

# Testing code is rather broken and merely for developer purposes, so disable it.
RESTRICT="test"

PATCHES="${FILESDIR}/ksystemtray-xgl.patch"

if use pertty;
then
	PATCHES="${PATCHES}
			 ${FILESDIR}/$P-rubberband.patch
			 ${FILESDIR}/$P-rounded-selection.patch
			 ${FILESDIR}/$P-khtml-image-selection-blend.patch
			 ${FILESDIR}/khtml-smoothscroll-3.5.5-final.patch"
fi

pkg_setup() {
	if use legacyssl ; then
		echo ""
		elog "You have the legacyssl use flag enabled, which fixes issues with some broken"
		elog "sites, but breaks others instead. It is strongly discouraged to use it."
		elog "For more information, see bug #128922."
		echo ""
	fi
	if ! use utempter ; then
		echo ""
		elog "On some setups that relies on the correct update of utmp records, not using"
		elog "utempter might not update them correctly. If you experience unexpected"
		elog "behaviour, try to rebuild kde-base/kdelibs with utempter use-flag enabled."
		echo ""
	fi
}

src_unpack() {
	kde_src_unpack
	if use legacyssl ; then
		# This patch won't be included upstream, see bug #128922
		epatch "${WORKDIR}/patches/kdelibs_3.5.4-kssl-3des.patch" || die "Patch did not apply."
	fi

	# Apply the following patch on the next revision of kdelibs-3.5.5 (fixes kde
	# bug #135409), which corrects a nasty regression in the cstyle indenter.
	epatch "${FILESDIR}/${P}-kate-cstyle-indenter-fix.diff"

	# Fix kdeprint timeout when trying to connect to cupsd. Bug #151261.
	# THIS DOES NOT SOLVE THE PROBLEM
	# epatch "${FILESDIR}/${P}-kdeprint-cupsd-timeout-fix.patch"

	epatch "${FILESDIR}/${P}-kdeprint.patch"

	# Fix rendering (see upstream bug #135639).
	epatch "${FILESDIR}/${P}-khtml.patch"

	# Allow notification with arts disabled
	epatch "${FILESDIR}/${P}-noarts.patch"
	epatch "${FILESDIR}/${P}-noarts-2.patch"

	# xinerama patch from Lubos Lunak
	# http://ktown.kde.org/~seli/xinerama/
	epatch "${DISTDIR}/${P}-seli-xinerama.patch.bz2"
}

src_compile() {
	rm -f "${S}/configure"

	myconf="--with-distribution=Gentoo --disable-fast-malloc
			$(use_enable fam libfam) $(use_enable kernel_linux dnotify)
			--with-libart --with-libidn
			$(use_with acl) $(use_with ssl)
			$(use_with alsa) $(use_with arts)
			$(use_with kerberos gssapi) $(use_with tiff)
			$(use_with jpeg2k jasper) $(use_with openexr)
			$(use_enable cups)
			$(use_with utempter) $(use_with lua)
			$(use_enable kernel_linux sendfile) --enable-mitshm
			$(use_with spell aspell)"

	if use zeroconf && ! use avahi; then
		myconf="${myconf} --enable-dnssd"
	else
		myconf="${myconf} --disable-dnssd"
	fi

	if use spell; then
		myconf="${myconf} $(use_with linguas_he hspell)"
	else
		myconf="${myconf} --without-hspell"
	fi

	if has_version x11-apps/rgb; then
		myconf="${myconf} --with-rgbfile=/usr/share/X11/rgb.txt"
	fi

	# fix bug 58179, bug 85593
	# kdelibs-3.4.0 needed -fno-gcse; 3.4.1 needs -mminimal-toc; this needs a
	# closer look... - corsair
	use ppc64 && append-flags "-mminimal-toc"

	# work around bug #120858, gcc 3.4.x -Os miscompilation
	use x86 && replace-flags "-Os" "-O2" # see bug #120858

	export BINDNOW_FLAGS="$(bindnow-flags)"

	kde_src_compile

	if use doc; then
		make apidox || die
	fi
}

src_install() {
	kde_src_install

	if use doc; then
		make DESTDIR="${D}" install-apidox || die
	fi

	# Needed to create lib -> lib64 symlink for amd64 2005.0 profile
	if [ "${SYMLINK_LIB}" = "yes" ]; then
		dosym $(get_abi_LIBDIR ${DEFAULT_ABI}) ${KDEDIR}/lib
	fi

	# Get rid of the disabled version of the kdnsd libraries
	if use zeroconf && use avahi; then
		rm -rf "${D}/${PREFIX}"/$(get_libdir)/libkdnssd.*
	fi

	dodir /etc/env.d

	# List all the multilib libdirs
	local libdirs
	for libdir in $(get_all_libdirs); do
		libdirs="${libdirs}:${PREFIX}/${libdir}"
	done

	cat <<EOF > "${D}"/etc/env.d/45kdepaths-${SLOT} # number goes down with version upgrade
PATH=${PREFIX}/bin
ROOTPATH=${PREFIX}/sbin:${PREFIX}/bin
LDPATH=${libdirs:1}
CONFIG_PROTECT="${PREFIX}/share/config ${PREFIX}/env ${PREFIX}/shutdown /usr/share/config"
KDEDIRS="${PREFIX}:/usr:/usr/local"
#KDE_IS_PRELINKED=1
EOF
}

pkg_postinst() {
	if use zeroconf; then
		echo
		elog "To make zeroconf support available in KDE make sure that the 'mdnsd' daemon"
		elog "is running. Make sure also that multicast dns lookups are enabled by editing"
		elog "the 'hosts:' line in /etc/nsswitch.conf to include 'mdns', e.g.:"
		elog "  hosts: files mdns dns"
		echo
	fi
}
