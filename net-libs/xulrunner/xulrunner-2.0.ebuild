# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/xulrunner/xulrunner-2.0.ebuild,v 1.1 2011/03/22 01:48:02 anarchy Exp $

EAPI="3"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib autotools python versionator pax-utils prefix

MAJ_XUL_PV="$(get_version_component_range 1-2)" # from mozilla-* branch name
MAJ_FF_PV="4.0"
FF_PV="${PV/${MAJ_XUL_PV}/${MAJ_FF_PV}}" # 3.7_alpha6, 3.6.3, etc.
FF_PV="${FF_PV/_alpha/a}" # Handle alpha for SRC_URI
FF_PV="${FF_PV/_beta/b}" # Handle beta for SRC_URI
FF_PV="${FF_PV/_rc/rc}" # Handle rc for SRC_URI
CHANGESET="e56ecd8b3a68"
PATCH="${PN}-2.0-patches-1.3"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"

KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
SLOT="1.9"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="+crashreporter +ipc system-sqlite +webm"

REL_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases"
# More URIs appended below...
SRC_URI="http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.bz2"

RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.9
	>=dev-libs/nspr-4.8.7
	>=dev-libs/glib-2.26
	x11-libs/pango[X]
	system-sqlite? ( >=dev-db/sqlite-3.7.4[fts3,secure-delete,unlock-notify,debug=] )
	webm? ( media-libs/libvpx
		media-libs/alsa-lib )
	!www-plugins/weave"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-lang/yasm"

if [[ ${PV} =~ alpha|beta ]]; then
	# hg snapshot tarball
	SRC_URI="${SRC_URI}
		http://dev.gentoo.org/~anarchy/mozilla/firefox/firefox-${FF_PV}_${CHANGESET}.source.tar.bz2"
	S="${WORKDIR}/mozilla-central"
else
	SRC_URI="${SRC_URI}
		${REL_URI}/${FF_PV}/source/firefox-${FF_PV}.source.tar.bz2"
	S="${WORKDIR}/mozilla-${MAJ_XUL_PV}"
fi

pkg_setup() {
	moz_pkgsetup
}

src_prepare() {
	# Apply our patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"

	# Allow user to apply any additional patches without modifing ebuild
	epatch_user

	eprefixify \
		extensions/java/xpcom/interfaces/org/mozilla/xpcom/Mozilla.java \
		xpcom/build/nsXPCOMPrivate.h \
		xulrunner/installer/Makefile.in \
		xulrunner/app/nsRegisterGREUnix.cpp

	# fix double symbols due to double -ljemalloc
	sed -i -e '/^LIBS += $(JEMALLOC_LIBS)/s/^/#/' \
		xulrunner/stub/Makefile.in || die

	# Same as in config/autoconf.mk.in
	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_XUL_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_XUL_PV}/sdk"

	# Gentoo install dirs
	sed -i -e "s:@PV@:${MAJ_XUL_PV}:" "${S}"/config/autoconf.mk.in \
		|| die "${MAJ_XUL_PV} sed failed!"

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Disable gnomevfs extension
	sed -i -e "s:gnomevfs::" "${S}/"xulrunner/confvars.sh \
		|| die "Failed to remove gnomevfs extension"

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

	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_XUL_PV}"

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --with-default-mozilla-five-home="${MOZLIBDIR}"
	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --enable-safe-browsing

	mozconfig_use_enable system-sqlite

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
	# Add our defaults to xulrunner and out of firefox
	cp "${FILESDIR}"/xulrunner-default-prefs.js \
		"${S}/dist/bin/defaults/pref/all-gentoo.js" || \
			die "failed to cp xulrunner-default-prefs.js"

	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${ED}"/usr/bin/xulrunner

	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_XUL_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_XUL_PV}/sdk"

	if has_multilib_profile; then
		local config
		for config in "${ED}"/etc/gre.d/*.system.conf ; do
			mv "${config}" "${config%.conf}.${CHOST}.conf"
		done
	fi

	dodir /usr/bin
	dosym "${MOZLIBDIR}/xulrunner" "/usr/bin/xulrunner-${MAJ_XUL_PV}" || die

	# env.d file for ld search path
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/${MOZLIBDIR}" > "${ED}"/etc/env.d/08xulrunner || die "env.d failed"

	pax-mark m "${ED}"/${MOZLIBDIR}/plugin-container
}
