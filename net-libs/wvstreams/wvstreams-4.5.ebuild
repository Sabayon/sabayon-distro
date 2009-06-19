# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/wvstreams/wvstreams-4.5.ebuild,v 1.1 2008/12/09 23:31:27 loki_val Exp $

EAPI=2

inherit autotools toolchain-funcs qt3 versionator

DESCRIPTION="A network programming library in C++"
HOMEPAGE="http://alumnit.ca/wiki/?WvStreams"
SRC_URI="http://wvstreams.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~sparc ~x86"
IUSE="qt3 pam doc +ssl +dbus debug"

#Tests fail if openssl is not compiled with -DPURIFY. Gentoo's isn't. FAIL!
RESTRICT="test"

#QA Fail: xplc is compiled as a part of wvstreams.
#It'll take a larger patching effort to get it extracted, since upstream integrated it
#more tightly this time. Probably for the better since upstream xplc seems dead.

RDEPEND="sys-libs/readline
	sys-libs/zlib
	dbus? (  sys-apps/dbus )
	dev-libs/openssl
	qt3? ( x11-libs/qt:3 )
	pam? ( sys-libs/pam )
	virtual/c++-tr1-functional"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )"

pkg_setup() {
	if has_version '>=sys-devel/gcc-4.1' && ! has_version '>=dev-libs/boost-1.34.1'
	then
		if ! version_is_at_least 4.1 "$(gcc-fullversion)"
		then
			eerror "This package needs the active gcc to be atleast of version 4.1"
			eerror "or for >=dev-libs/boost-1.34.1 to be installed"
			die "Please activate >=sys-devel/gcc-4.1 with gcc-config"
		fi
	fi
}

src_prepare() {
	#Fixes Fedora 402531:
	#https://bugzilla.redhat.com/show_bug.cgi?id=402531
	epatch "${FILESDIR}/${P}-no_sarestorer.patch"
	epatch "${FILESDIR}/${PN}-4.4.1-MOC-fix.patch"
	epatch "${FILESDIR}/${P}-valgrind-optional.patch"
	#Imported from Fedora CVS
	epatch "${FILESDIR}/${P}-gcc43.patch"
	epatch "${FILESDIR}/${P}-configure.patch"
	epatch "${FILESDIR}/${P}-parallel-make.patch"
	epatch "${FILESDIR}/${P}-dbus-configure-fix.patch"
	epatch "${FILESDIR}/${P}-qt-fixup.patch"

	#epatch "${FILESDIR}/${P}-const-correctness.patch"
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	export CXX=$(tc-getCXX)

	econf	$(use_with pam) \
		$(use_with qt3 qt) \
		$(use_enable debug) \
		$(use_with dbus) \
		--without-valgrind \
		--with-openssl \
		--disable-optimization \
		--enable-warnings \
		--without-tcl \
		--with-zlib \
		|| die "configure failed"
}

src_compile() {
	emake || die "compile failed"
	use doc && doxygen
}

src_test() {
	emake test
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use doc ; then
		#the list of files is too big for dohtml -r Docs/doxy-html/*
		cd Docs/doxy-html
		dohtml -r *
	fi
}
