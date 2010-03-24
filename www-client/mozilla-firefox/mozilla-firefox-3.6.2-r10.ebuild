# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-firefox/mozilla-firefox-3.6.2.ebuild,v 1.1 2010/03/24 12:51:04 nirbheek Exp $
EAPI="2"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib pax-utils fdo-mime autotools mozextension java-pkg-opt-2

LANGS="af ar as be bg bn-BD bn-IN ca cs cy da de el en en-GB en-US eo es-AR
es-CL es-ES es-MX et eu fa fi fr fy-NL ga-IE gl gu-IN he hi-IN hr hu id is it ja
ka kk kn ko ku lt lv mk ml mr nb-NO nl nn-NO oc or pa-IN pl pt-BR pt-PT rm ro ru
si sk sl sq sr sv-SE ta ta-LK te th tr uk vi zh-CN zh-TW"
NOSHORTLANGS="en-GB es-AR es-CL es-MX pt-BR zh-CN zh-TW"

MAJ_XUL_PV="1.9.2"
MAJ_PV="${PV/_*/}" # Without the _rc and _beta stuff
DESKTOP_PV="3.6"
MY_PV="${PV/_rc/rc}" # Handle beta for SRC_URI
XUL_PV="${MAJ_XUL_PV}${MAJ_PV/${DESKTOP_PV}/}" # Major + Minor version no.s
PATCH="${PN}-3.6-patches-0.6"

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="+alsa bindist java libnotify system-sqlite wifi"

REL_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases"
SRC_URI="${REL_URI}/${MY_PV}/source/firefox-${MY_PV}.source.tar.bz2
	http://dev.gentoo.org/~anarchy/dist/${PATCH}.tar.bz2"

for X in ${LANGS} ; do
	if [ "${X}" != "en" ] && [ "${X}" != "en-US" ]; then
		SRC_URI="${SRC_URI}
			linguas_${X/-/_}? ( ${REL_URI}/${MY_PV}/linux-i686/xpi/${X}.xpi -> ${P}-${X}.xpi )"
	fi
	IUSE="${IUSE} linguas_${X/-/_}"
	# english is handled internally
	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTLANGS}; then
		if [ "${X}" != "en-US" ]; then
			SRC_URI="${SRC_URI}
				linguas_${X%%-*}? ( ${REL_URI}/${PV}/linux-i686/xpi/${X}.xpi -> ${P}-${X}.xpi )"
		fi
		IUSE="${IUSE} linguas_${X%%-*}"
	fi
done

RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.4
	>=dev-libs/nspr-4.8
	>=app-text/hunspell-1.2
	system-sqlite? ( >=dev-db/sqlite-3.6.22-r2[fts3,secure-delete] )
	alsa? ( media-libs/alsa-lib )
	>=x11-libs/cairo-1.8.8[X]
	x11-libs/pango[X]
	wifi? ( net-wireless/wireless-tools )
	libnotify? ( >=x11-libs/libnotify-0.4 )
	~net-libs/xulrunner-${XUL_PV}[java=,wifi=,libnotify=,system-sqlite=]"

DEPEND="${RDEPEND}
	java? ( >=virtual/jdk-1.4 )
	dev-util/pkgconfig"

RDEPEND="${RDEPEND} java? ( >=virtual/jre-1.4 )"

S="${WORKDIR}/mozilla-1.9.2"

QA_PRESTRIPPED="usr/$(get_libdir)/${PN}/firefox"

linguas() {
	local LANG SLANG
	for LANG in ${LINGUAS}; do
		if has ${LANG} en en_US; then
			has en ${linguas} || linguas="${linguas:+"${linguas} "}en"
			continue
		elif has ${LANG} ${LANGS//-/_}; then
			has ${LANG//_/-} ${linguas} || linguas="${linguas:+"${linguas} "}${LANG//_/-}"
			continue
		elif [[ " ${LANGS} " == *" ${LANG}-"* ]]; then
			for X in ${LANGS}; do
				if [[ "${X}" == "${LANG}-"* ]] && \
					[[ " ${NOSHORTLANGS} " != *" ${X} "* ]]; then
					has ${X} ${linguas} || linguas="${linguas:+"${linguas} "}${X}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${PN} does not support the ${LANG} LINGUA"
	done
}

pkg_setup() {
	# Ensure we always build with C locale.
	export LANG="C"
	export LC_ALL="C"
	export LC_MESSAGES="C"
	export LC_CTYPE="C"

	if ! use bindist ; then
		einfo
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"
	fi

	java-pkg-opt-2_pkg_setup
}

src_unpack() {
	unpack firefox-${MY_PV}.source.tar.bz2 ${PATCH}.tar.bz2

	linguas
	for X in ${linguas}; do
		# FIXME: Add support for unpacking xpis to portage
		[[ ${X} != "en" ]] && xpi_unpack "${P}-${X}.xpi"
	done
}

src_prepare() {
	# Apply our patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"

	# Fix media build failure
	epatch "${FILESDIR}/xulrunner-1.9.2-noalsa-fixup.patch"

	# Fix broken alignment
	epatch "${FILESDIR}/1000_fix_alignment.patch"

	eautoreconf

	cd js/src
	eautoreconf
}

src_configure() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS="default"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --enable-application=browser
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
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --with-system-bz2
	mozconfig_annotate '' --with-system-libxul
	mozconfig_annotate '' --with-libxul-sdk=/usr/$(get_libdir)/xulrunner-devel-${MAJ_XUL_PV}

	mozconfig_use_enable libnotify
	mozconfig_use_enable java javaxpcom
	mozconfig_use_enable wifi necko-wifi
	mozconfig_use_enable alsa ogg
	mozconfig_use_enable alsa wave
	mozconfig_use_enable system-sqlite
	mozconfig_use_enable !bindist official-branding

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	####################################
	#
	#  Configure and build
	#
	####################################

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" econf
}

src_compile() {
	# Should the build use multiprocessing? Not enabled by default, as it tends to break
	[ "${WANT_MP}" = "true" ] && jobs=${MAKEOPTS} || jobs="-j1"
	emake ${jobs} || die
}

src_install() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	emake DESTDIR="${D}" install || die "emake install failed"

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_install "${WORKDIR}"/"${P}-${X}"
	done

	# Install icon and .desktop for menu entry
	if ! use bindist ; then
		newicon "${S}"/other-licenses/branding/firefox/content/icon48.png firefox-icon.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5.desktop \
			${PN}-${DESKTOP_PV}.desktop
	else
		newicon "${S}"/browser/branding/unofficial/content/icon48.png firefox-icon-unbranded.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5-unbranded.desktop \
			${PN}-${DESKTOP_PV}.desktop
		sed -i -e "s:Bon Echo:Namoroka:" \
			"${D}"/usr/share/applications/${PN}-${DESKTOP_PV}.desktop || die "sed failed!"
	fi

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" >> "${D}"/usr/share/applications/${PN}-${DESKTOP_PV}.desktop
	fi

	pax-mark m "${D}"/${MOZILLA_FIVE_HOME}/firefox

	# Enable very specific settings not inherited from xulrunner
	cp "${FILESDIR}"/firefox-default-prefs.js \
		"${D}/${MOZILLA_FIVE_HOME}/defaults/preferences/all-gentoo.js" || \
		die "failed to cp firefox-default-prefs.js"

	# Plugins dir
	dosym ../nsbrowser/plugins "${MOZILLA_FIVE_HOME}"/plugins \
		|| die "failed to symlink"

	# very ugly hack to make firefox not sigbus on sparc
	use sparc && { sed -e 's/Firefox/FirefoxGentoo/g' \
					 -i "${D}/${MOZILLA_FIVE_HOME}/application.ini" || \
					 die "sparc sed failed"; }
}

pkg_postinst() {
	ewarn "All the packages built against ${PN} won't compile,"
	ewarn "any package that fails to build warrants a bug report."
	elog

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
}
