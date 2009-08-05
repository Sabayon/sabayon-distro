# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib fdo-mime autotools mozextension mercurial

EHG_REPO_URI="http://hg.mozilla.org/mozilla-central"

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS=""
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"

IUSE_INTERNAL="internal_cairo +internal_lcms +internal_nspr +internal_nss +internal_sqlite"
IUSE="${IUSE_INTERNAL}
	abouttab bindist iceweasel java mozdevelop ogg restrict-javascript spell libnotify"

SRC_URI="iceweasel? ( mirror://gentoo/iceweasel-icons-3.0.tar.bz2 )"

RDEPEND=">=sys-devel/binutils-2.16.1
	x11-libs/pango[X]
	java? ( virtual/jre )
	ogg? ( media-libs/alsa-lib
			media-libs/libtheora
			media-libs/libogg )
	spell? ( >=app-text/hunspell-1.1.9 )
	!internal_cairo? ( x11-libs/cairo[X] )
	!internal_lcms? ( >=media-libs/lcms-1.17 )
	!internal_nss? ( >=dev-libs/nss-3.12.2 )
	!internal_nspr? ( >=dev-libs/nspr-4.7.4 )
	!internal_sqlite? ( >=dev-db/sqlite-3.6.8 )
	!!www-client/mozilla-firefox-bin"

DEPEND="${RDEPEND}
	libnotify? ( >=x11-libs/libnotify-0.4.4 )
	dev-util/pkgconfig
	java? ( >=dev-java/java-config-0.2.0 )"

PDEPEND="abouttab? ( x11-plugins/abouttab )
	restrict-javascript? ( x11-plugins/noscript )"

S="${WORKDIR}/mozilla-central"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=browser
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

pkg_setup() {
	if ! use bindist && ! use iceweasel; then
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"
	fi
}

src_unpack() {
	mercurial_src_unpack

	if use iceweasel; then
		unpack iceweasel-icons-3.0.tar.bz2
		cp -r iceweaselicons/browser/app/* mozilla/browser/branding/unofficial
		cp iceweaselicons/browser/base/branding/icon48.png mozilla/browser/branding/unofficial/default48.png
		cp -r iceweaselicons/browser/base/branding/* mozilla/browser/branding/unofficial/content
	fi

	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${FILESDIR}"/9999-patches

	if use iceweasel; then
		sed -i -e "s|Minefield|Iceweasel|" browser/locales/en-US/chrome/branding/brand.* \
			browser/branding/nightly/configure.sh
	fi

	eautoreconf
	cd js/src
	eautoreconf
}

src_configure() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS="default"

	mozconfig_init
	mozconfig_config

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# --as-needed breaks us
	filter-ldflags "-Wl,--as-needed" "--as-needed"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-mochitest
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places

#	mozconfig_use_enable mozdevelop jsd
#	mozconfig_use_enable mozdevelop xpctools
#	mozconfig_use_extension mozdevelop venkman

	mozconfig_annotate '' --with-default-mozilla-five-home="${MOZILLA_FIVE_HOME}"

	# Use flags for disabling/enabling internal parts
	if ! use internal_sqlite; then
		mozconfig_annotate '' --enable-system-sqlite
	else
		mozconfig_annotate '' --disable-system-sqlite
	fi

	if ! use internal_nspr; then
		mozconfig_annotate '' --with-system-nspr
	else
		mozconfig_annotate '' --without-system-nspr
	fi

	if ! use internal_nss; then
		mozconfig_annotate '' --with-system-nss
	else
		mozconfig_annotate '' --without-system-nss
	fi

	if ! use internal_lcms; then
		mozconfig_annotate '' --enable-system-lcms
	else
		mozconfig_annotate '' --disable-system-lcms
	fi

	if ! use internal_cairo; then
		mozconfig_annotate '' --enable-system-cairo
	else
		mozconfig_annotate '' --disable-system-cairo
	fi

	# General use flags
	if ! use bindist && ! use iceweasel; then
		mozconfig_annotate '' --enable-official-branding
	elif use bindist && ! use iceweasel; then
		mozconfig_annotate 'bindist' --with-branding=browser/branding/unofficial
	fi

	if use spell; then
		mozconfig_annotate '' --enable-system-hunspell
	else
		mozconfig_annotate '' --disable-system-hunspell
	fi

	if use ogg; then
		mozconfig_annotate '' --enable-ogg
	else
		mozconfig_annotate '' --disable-ogg
	fi

	if use libnotify; then
		mozconfig_annotate '' --enable-libnotify
	else
		mozconfig_annotate '' --disable-libnotify
	fi

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die "econf failed"
}

#src_compile() {
	# Should the build use multiprocessing? Not enabled by default, as it tends to break
#	[ "${WANT_MP}" = "true" ] && jobs=${MAKEOPTS} || jobs="-j1"
#	emake ${jobs} || die "emake failed"
#}

pkg_preinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	einfo "Removing old installs with some really ugly code.  It potentially"
	einfo "eliminates any problems during the install, however suggestions to"
	einfo "replace this are highly welcome.  Send comments and suggestions to"
	einfo "mozilla@gentoo.org."
	rm -rf "${ROOT}"${MOZILLA_FIVE_HOME}
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	emake DESTDIR="${D}" install || die "emake install failed"
	rm "${D}"/usr/bin/firefox

	cp "${FILESDIR}"/firefox-default-prefs.js "${D}"${MOZILLA_FIVE_HOME}/defaults/pref/all-gentoo.js

	# Install icon and .desktop for menu entry
	if use iceweasel; then
		newicon "${S}"/browser/base/branding/icon48.png iceweasel-icon.png
		newmenu "${FILESDIR}"/icon/iceweasel.desktop \
			mozilla-firefox-3.6a1pre.desktop
	elif ! use bindist; then
		newicon "${S}"/other-licenses/branding/firefox/content/icon48.png firefox-icon.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5.desktop \
			mozilla-firefox-3.6a1pre.desktop
	else
		newicon "${S}"/browser/base/branding/icon48.png firefox-icon-unbranded.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5-unbranded.desktop \
			mozilla-firefox-3.6a1pre.desktop
		sed -i -e "s/Bon Echo/Shiretoko/" "${D}"/usr/share/applications/mozilla-firefox-3.6a1pre.desktop
	fi

	# Create /usr/bin/firefox
	make_wrapper firefox "${MOZILLA_FIVE_HOME}/firefox"

	# Add vendor
	echo "pref(\"general.useragent.vendor\",\"Sabayon\");" \
		>> "${D}"${MOZILLA_FIVE_HOME}/defaults/pref/vendor.js

	# Plugins dir
	ln -s "${D}/usr/$(get_libdir)/nsbrowser/plugins" \
		"${D}/usr/$(get_libdir)/mozilla-firefox/plugins"

	echo "MOZ_PLUGIN_PATH=/usr/$(get_libdir)/nsbrowser/plugins" > 66firefox
	doenvd 66firefox
}

pkg_postinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update

	use abouttab && ewarn "You need to reinstall x11-plugins/abouttab after updating ${PN}."
	use restrict-javascript && ewarn "You need to reinstall x11-plugins/noscript after updating ${PN}."

}
