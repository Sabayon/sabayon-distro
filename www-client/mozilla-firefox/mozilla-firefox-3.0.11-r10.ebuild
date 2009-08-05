# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-firefox/mozilla-firefox-3.0.11.ebuild,v 1.6 2009/06/18 01:40:50 ranger Exp $
EAPI="2"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib fdo-mime autotools mozextension
PATCH="${PN}-3.0.10-patches-0.1"

LANGS="af ar be bg bn-IN ca cs cy da de el en-GB en-US eo es-AR es-ES et eu fi fr fy-NL ga-IE gl gu-IN he hi-IN hu id is it ja ka kn ko ku lt lv mk mn mr nb-NO nl nn-NO oc pa-IN pl pt-BR pt-PT ro ru si sk sl sq sr sv-SE te th tr uk zh-CN zh-TW"
NOSHORTLANGS="en-GB es-AR pt-BR zh-CN"

MY_PV=${PV/3/}
MY_PVR=${PVR/3/}

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS="alpha ~amd64 arm hppa ia64 ppc ppc64 sparc x86"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="java mozdevelop bindist restrict-javascript iceweasel +xulrunner"

SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~armin76/dist/${P}.tar.bz2
	mirror://gentoo/${PATCH}.tar.bz2
	http://dev.gentoo.org/~armin76/dist/${PATCH}.tar.bz2
	iceweasel? ( mirror://gentoo/iceweasel-icons-3.0.tar.bz2 )
	!xulrunner? ( mirror://gentoo/xulrunner-1.9${MY_PV}.tar.bz2 )"

REL_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases"
for X in ${LANGS} ; do
	if [ "${X}" != "en" ] && [ "${X}" != "en-US" ]; then
		SRC_URI="${SRC_URI}
			linguas_${X/-/_}? ( ${REL_URI}/${PV}/linux-i686/xpi/${X}.xpi -> ${P}-${X}.xpi )"
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

RDEPEND="java? ( virtual/jre )
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.2
	>=dev-libs/nspr-4.7.4
	>=app-text/hunspell-1.1.9
	>=media-libs/lcms-1.17
	x11-libs/cairo[X]
	x11-libs/pango[X]
	xulrunner? ( >=net-libs/xulrunner-1.9${MY_PVR} )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	java? ( >=dev-java/java-config-0.2.0 )"

PDEPEND="restrict-javascript? ( x11-plugins/noscript )"

S="${WORKDIR}/mozilla"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=browser
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

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
		ewarn "Sorry, but mozilla-firefox does not support the ${LANG} LINGUA"
	done
}

pkg_setup(){
	if ! use bindist && ! use iceweasel; then
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"

	fi
}

src_unpack() {
	! use xulrunner && unpack xulrunner-1.9${MY_PV}.tar.bz2
	unpack ${P}.tar.bz2 ${PATCH}.tar.bz2

	if use iceweasel; then
		unpack iceweasel-icons-3.0.tar.bz2

		cp -r iceweaselicons/browser/app/* mozilla/browser/branding/unofficial
		cp iceweaselicons/browser/base/branding/icon48.png mozilla/browser/branding/unofficial/default48.png
		cp -r iceweaselicons/browser/base/branding/* mozilla/browser/branding/unofficial/content
	fi

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_unpack "${P}-${X}.xpi"
	done
	if [[ ${linguas} != "" && ${linguas} != "en" ]]; then
		einfo "Selected language packs (first will be default): ${linguas}"
	fi
}

src_prepare() {
	# Remove the patches we don't need
	use xulrunner && rm "${WORKDIR}"/patch/*noxul* || rm "${WORKDIR}"/patch/*xulonly*

	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"/patch

	if use iceweasel; then
		sed -i -e "s|Gran Paradiso|Iceweasel|" browser/branding/unofficial/locales/en-US/brand.*
		sed -i -e "s|GranParadiso|Iceweasel|" browser/branding/unofficial/configure.sh
	fi

	eautoreconf

	# We need to re-patch this because autoreconf overwrites it
	epatch "${WORKDIR}"/patch/000_flex-configure-LANG.patch
}

src_configure() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS="default,typeaheadfind"

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
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-mochitest
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-system-hunspell
	#mozconfig_annotate '' --enable-system-sqlite
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places

	# Other ff-specific settings
	#mozconfig_use_enable mozdevelop jsd
	#mozconfig_use_enable mozdevelop xpctools
	mozconfig_use_extension mozdevelop venkman
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}
	if use xulrunner; then
		# Add xulrunner variable
		mozconfig_annotate '' --with-libxul-sdk=/usr/$(get_libdir)/xulrunner-1.9
	fi

	if ! use bindist && ! use iceweasel ; then
		mozconfig_annotate '' --enable-official-branding
	elif use bindist || use iceweasel ; then
		mozconfig_annotate 'bindist' --with-branding=browser/branding/unofficial
	fi

	# Finalize and report settings
	mozconfig_final

	####################################
	#
	#  Configure and build
	#
	####################################

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die

	# It would be great if we could pass these in via CPPFLAGS or CFLAGS prior
	# to econf, but the quotes cause configure to fail.
	sed -i -e \
		's|-DARON_WAS_HERE|-DGENTOO_NSPLUGINS_DIR=\\\"/usr/'"$(get_libdir)"'/nsplugins\\\" -DGENTOO_NSBROWSER_PLUGINS_DIR=\\\"/usr/'"$(get_libdir)"'/nsbrowser/plugins\\\"|' \
		"${S}"/config/autoconf.mk \
		"${S}"/toolkit/content/buildconfig.html
}

src_compile() {
	# Should the build use multiprocessing? Not enabled by default, as it tends to break
	[ "${WANT_MP}" = "true" ] && jobs=${MAKEOPTS} || jobs="-j1"
	emake ${jobs} || die
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	emake DESTDIR="${D}" install || die "emake install failed"
	rm "${D}"/usr/bin/firefox

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_install "${WORKDIR}"/"${P}-${X}"
	done

	use xulrunner && prefs=preferences || prefs=pref
	cp "${FILESDIR}"/firefox-default-prefs.js "${D}"${MOZILLA_FIVE_HOME}/defaults/${prefs}/all-gentoo.js

	local LANG=${linguas%% *}
	if [[ -n ${LANG} && ${LANG} != "en" ]]; then
		elog "Setting default locale to ${LANG}"
		dosed -e "s:general.useragent.locale\", \"en-US\":general.useragent.locale\", \"${LANG}\":" \
			${MOZILLA_FIVE_HOME}/defaults/${prefs}/firefox.js \
			${MOZILLA_FIVE_HOME}/defaults/${prefs}/firefox-l10n.js || \
			die "sed failed to change locale"
	fi

	# Install icon and .desktop for menu entry
	if use iceweasel; then
		newicon "${S}"/browser/branding/unofficial/default48.png iceweasel-icon.png
		newmenu "${FILESDIR}"/"${PV}"/icon/iceweasel.desktop \
			mozilla-firefox-3.0.desktop
	elif ! use bindist; then
		newicon "${S}"/other-licenses/branding/firefox/content/icon48.png firefox-icon.png
		newmenu "${FILESDIR}"/"${PV}"/icon/mozilla-firefox-1.5.desktop \
			mozilla-firefox-3.0.desktop
	else
		newicon "${S}"/browser/base/branding/icon48.png firefox-icon-unbranded.png
		newmenu "${FILESDIR}"/"${PV}"/icon/mozilla-firefox-1.5-unbranded.desktop \
			mozilla-firefox-3.0.desktop
		sed -i -e "s/Bon Echo/Gran Paradiso/" "${D}"/usr/share/applications/mozilla-firefox-3.0.desktop
	fi

	if use xulrunner; then
		# Create /usr/bin/firefox
		cat <<EOF >"${D}"/usr/bin/firefox
#!/bin/sh
export LD_LIBRARY_PATH="${MOZILLA_FIVE_HOME}"
exec "${MOZILLA_FIVE_HOME}"/firefox "\$@"
EOF
		fperms 0755 /usr/bin/firefox
	else
		# Create /usr/bin/firefox
		make_wrapper firefox "${MOZILLA_FIVE_HOME}/firefox"

		# Add vendor
	    echo "pref(\"general.useragent.vendor\",\"Sabayon\");" \
		    >> "${D}"${MOZILLA_FIVE_HOME}/defaults/pref/vendor.js
	fi

}

pkg_postinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	ewarn "All the packages built against ${PN} won't compile,"
	ewarn "if after installing firefox 3.0 you get some blockers,"
	ewarn "please add 'xulrunner' to your USE-flags."

	if use xulrunner; then
		ln -s /usr/$(get_libdir)/xulrunner-1.9/defaults/autoconfig \
			${MOZILLA_FIVE_HOME}/defaults/autoconfig
	fi

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
}
