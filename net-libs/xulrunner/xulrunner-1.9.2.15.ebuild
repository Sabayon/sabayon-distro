# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/xulrunner/xulrunner-1.9.2.15.ebuild,v 1.3 2011/03/07 13:01:21 jer Exp $

EAPI="3"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib java-pkg-opt-2 autotools python prefix pax-utils

MY_PV="${PV/_rc/rc}" # Handle beta
MY_PV="${MY_PV/1.9.2/3.6}"
MAJ_PV="1.9.2" # from mozilla-* branch name
PATCH="${PN}-1.9.2-patches-0.9"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases/${MY_PV}/source/firefox-${MY_PV}.source.tar.bz2
	http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.bz2"

KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="1.9"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="+alsa debug +ipc libnotify system-sqlite wifi"

RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.8
	>=dev-libs/nspr-4.8.6
	system-sqlite? ( >=dev-db/sqlite-3.7.1[fts3,secure-delete] )
	alsa? ( media-libs/alsa-lib )
	>=app-text/hunspell-1.2
	>=x11-libs/cairo-1.8.8[X]
	x11-libs/pango[X]
	x11-libs/libXt
	x11-libs/pixman
	>=dev-libs/libevent-1.4.7
	wifi? ( net-wireless/wireless-tools )
	libnotify? ( >=x11-libs/libnotify-0.4 )"

DEPEND="java? ( >=virtual/jdk-1.4 )
	${RDEPEND}
	=dev-lang/python-2*[threads]
	dev-util/pkgconfig"

# virtual/jre should not be in DEPEND. bug 325981
RDEPEND="java? ( >=virtual/jre-1.4 ) ${RDEPEND}"

S="${WORKDIR}/mozilla-${MAJ_PV}"

pkg_setup() {
	# Ensure we always build with C locale.
	export LANG="C"
	export LC_ALL="C"
	export LC_MESSAGES="C"
	export LC_CTYPE="C"

	java-pkg-opt-2_pkg_setup

	python_set_active_version 2
}

src_prepare() {
	# Apply our patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"

	epatch "${FILESDIR}/bug-606109.patch"
	epatch "${FILESDIR}/fix-animated-gifs.patch"
	epatch "${FILESDIR}/libnotify-0.7.patch"

	eprefixify \
		extensions/java/xpcom/interfaces/org/mozilla/xpcom/Mozilla.java \
		xpcom/build/nsXPCOMPrivate.h \
		xulrunner/installer/Makefile.in \
		xulrunner/app/nsRegisterGREUnix.cpp

	# fix double symbols due to double -ljemalloc
	sed -i -e '/^LIBS += $(JEMALLOC_LIBS)/s/^/#/' \
		xulrunner/stub/Makefile.in || die

	# Allow user to apply additional patches without modifing ebuild
	epatch_user

	# Same as in config/autoconf.mk.in
	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_PV}/sdk"

	# Gentoo install dirs
	sed -i -e "s:@PV@:${MAJ_PV}:" "${S}"/config/autoconf.mk.in \
		|| die "${MAJ_PV} sed failed!"

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	eautoreconf

	cd js/src
	eautoreconf
}

src_configure() {
	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	MEXTENSIONS="default"

	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_PV}"

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --with-default-mozilla-five-home="${MOZLIBDIR}"
	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --enable-application=xulrunner
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate 'gtk' --enable-default-toolkit=cairo-gtk2
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places
	mozconfig_annotate '' --enable-safe-browsing

	# Build mozdevelop permately
	mozconfig_annotate ''  --enable-jsd --enable-xpctools

	# System-wide install specs
	mozconfig_annotate '' --disable-installer
	mozconfig_annotate '' --disable-updater
	mozconfig_annotate '' --disable-strip
	mozconfig_annotate '' --disable-install-strip

	# Use system libraries
	mozconfig_annotate '' --enable-system-cairo
	mozconfig_annotate '' --enable-system-hunspell
	mozconfig_annotate '' --with-system-nspr --with-nspr-prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --with-system-nss --with-nss-prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --x-includes="${EPREFIX}"/usr/include --x-libraries="${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate '' --with-system-bz2
	mozconfig_annotate '' --with-system-libevent="${EPREFIX}"/usr

	mozconfig_use_enable ipc # +ipc, upstream default
	mozconfig_use_enable libnotify
	mozconfig_use_enable java javaxpcom
	mozconfig_use_enable wifi necko-wifi
	mozconfig_use_enable alsa ogg
	mozconfig_use_enable alsa wave
	mozconfig_use_enable system-sqlite

	# Debug
	if use debug ; then
		mozconfig_annotate 'debug' --disable-optimize
		mozconfig_annotate 'debug' --enable-debug=-ggdb
		mozconfig_annotate 'debug' --enable-debug-modules=all
		mozconfig_annotate 'debug' --enable-debugger-info-modules
	fi

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-flags -fno-stack-protector
	fi

	####################################
	#
	#  Configure and build
	#
	####################################

	# Disable no-print-directory
	MAKEOPTS=${MAKEOPTS/--no-print-directory/}

	# Ensure that are plugins dir is enabled as default
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/$(get_libdir)/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path!"

	# hack added to workaround bug 299905 on hosts with libc that doesn't
	# support tls, (probably will only hit this condition with Gentoo Prefix)
	tc-has-tls -l || export ac_cv_thread_keyword=no

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" PYTHON="$(PYTHON)" econf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${ED}"/usr/bin/xulrunner

	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_PV}/sdk"

	if has_multilib_profile; then
		local config
		for config in "${ED}"/etc/gre.d/*.system.conf ; do
			mv "${config}" "${config%.conf}.${CHOST}.conf"
		done
	fi

	dodir /usr/bin
	dosym "${MOZLIBDIR}/xulrunner" "/usr/bin/xulrunner-${MAJ_PV}" || die

	# env.d file for ld search path
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/${MOZLIBDIR}" > "${ED}"/etc/env.d/08xulrunner || die "env.d failed"

	# Add our defaults to xulrunner and out of firefox
	cp "${FILESDIR}"/xulrunner-default-prefs.js \
		"${ED}/${MOZLIBDIR}/defaults/pref/all-gentoo.js" || \
			die "failed to cp xulrunner-default-prefs.js"

	pax-mark m "${D}"/${MOZLIBDIR}/plugin-container

	if use java ; then
		java-pkg_regjar "${ED}/${MOZLIBDIR}/javaxpcom.jar"
		java-pkg_regso "${ED}/${MOZLIBDIR}/libjavaxpcomglue.so"
		java-pkg_regjar "${ED}/${SDKDIR}/lib/MozillaGlue.jar"
		java-pkg_regjar "${ED}/${SDKDIR}/lib/MozillaInterfaces.jar"
	fi
}

pkg_postinst() {
	ewarn "If firefox fails to start with \"failed to load xpcom\", run revdep-rebuild"
	ewarn "If that does not fix the problem, rebuild dev-libs/nss"
	ewarn "Try dev-util/lafilefixer if you get build failures related to .la files"

	einfo
	einfo "All prefs can be overridden by the user. The preferences are to make"
	einfo "use of xulrunner out of the box on an average system without the user"
	einfo "having to go through and enable the basics."

	einfo
	ewarn "Any package that requires xulrunner:1.9 slot could and most likely will"
	ewarn "have issues. These issues should be reported to maintainer, and mozilla herd"
	ewarn "should be cc'd on the bug report. Thank you anarchy@gentoo.org ."
}
