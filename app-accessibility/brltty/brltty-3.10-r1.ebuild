# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-accessibility/brltty/brltty-3.10.ebuild,v 1.8 2009/02/06 05:11:39 jer Exp $

FINDLIB_USE="ocaml"

inherit autotools findlib eutils multilib toolchain-funcs java-pkg-opt-2 flag-o-matic

DESCRIPTION="Daemon that provides access to the Linux/Unix console for a blind person"
HOMEPAGE="http://mielke.cc/brltty/"
SRC_URI="http://mielke.cc/brltty/releases/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 x86"
IUSE="bluetooth doc gpm iconv icu java nls ocaml python usb tcl X"

COMMON_DEP="bluetooth? ( || ( net-wireless/bluez net-wireless/bluez-libs ) )
	gpm? ( >=sys-libs/gpm-1.20 )
	iconv? ( virtual/libiconv )
	icu? ( dev-libs/icu )
	nls? ( virtual/libintl )
	python? ( >=dev-python/pyrex-0.9.4.1 )
	tcl? ( >=dev-lang/tcl-8.4.15 )
	usb? ( >=dev-libs/libusb-0.1.12-r1 )
	X? ( x11-libs/libXaw )"
DEPEND="java? ( >=virtual/jdk-1.4 )
	${COMMON_DEP}"
RDEPEND="java? ( >=virtual/jre-1.4 )
	${COMMON_DEP}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-3.9-gnusource.patch
	epatch "${FILESDIR}"/${PN}-3.9-parallel.patch
	epatch "${FILESDIR}"/${PN}-3.9-autoconf.patch
	epatch "${FILESDIR}"/${PN}-3.10-api-socket-dir.patch

	eautoconf
}

src_compile() {
	local JAVAC_CONF=""
	if use java; then
		append-flags "$(java-pkg_get-jni-cflags)"
		JAVAC_CONF="${JAVAC} -encoding UTF-8 $(java-pkg_javac-args)"
	fi

	# override prefix in order to install into /
	# braille terminal needs to be available as soon in the boot process as
	# possible
	econf \
		--prefix=/ \
		--includedir=/usr/include \
		$(use_enable bluetooth bluetooth-support) \
		$(use_enable gpm) \
		$(use_enable iconv) \
		$(use_enable icu) \
		$(use_enable java java-bindings) \
		$(use_enable nls i18n) \
		$(use_enable ocaml caml-bindings) \
		$(use_enable python python-bindings) \
		$(use_enable usb usb-support) \
		$(use_enable tcl tcl-bindings) \
		$(use_enable X x) \
		|| die
	emake JAVAC="${JAVAC_CONF}" || die
}

src_install() {
	if use ocaml; then
		findlib_src_preinst
	fi
	emake INSTALL_PROGRAM="\${INSTALL_SCRIPT}" INSTALL_ROOT="${D}" install || die

	if use java; then
		# make install puts the _java.so there, and no it's not $(get_libdir)
		rm -rf "${D}/usr/lib/java"
		java-pkg_doso Bindings/Java/libbrlapi_java.so
		java-pkg_dojar Bindings/Java/brlapi.jar
	fi

	cd Documents
	rm *.made
	dodoc ChangeLog README* Manual.* TODO
	dohtml -r Manual-HTML
	if use doc; then
		dodoc BrlAPI.* BrlAPIref.doxy
		dohtml -r BrlAPI-HTML BrlAPIref-HTML
	fi

	insinto /etc
	doins brltty.conf
	newinitd "${FILESDIR}"/brltty.rc brltty

	libdir="$(get_libdir)"
	mkdir -p "${D}"/usr/${libdir}/
	mv "${D}"/${libdir}/*.a "${D}"/usr/${libdir}/
	gen_usr_ldscript libbrlapi.so
#	TMPDIR=../../Programs scanelf -RBXr "${D}" -o /dev/null
}

pkg_postinst() {
	elog
	elog please be sure "${ROOT}"etc/brltty.conf is correct for your system.
	elog
	elog To make brltty start on boot, type this command as root:
	elog
	elog rc-update add brltty boot
}
