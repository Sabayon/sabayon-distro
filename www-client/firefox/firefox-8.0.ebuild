# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/firefox/firefox-8.0.ebuild,v 1.1 2011/11/11 01:36:32 anarchy Exp $

EAPI="3"
VIRTUALX_REQUIRED="pgo"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-3 multilib pax-utils fdo-mime autotools mozextension versionator python virtualx

MAJ_FF_PV="$(get_version_component_range 1-2)" # 3.5, 3.6, 4.0, etc.
FF_PV="${PV/_alpha/a}" # Handle alpha for SRC_URI
FF_PV="${FF_PV/_beta/b}" # Handle beta for SRC_URI
FF_PV="${FF_PV/_rc/rc}" # Handle rc for SRC_URI
CHANGESET="e56ecd8b3a68"
PATCH="${PN}-8.0-patches-0.2"

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="bindist +crashreporter +ipc pgo system-sqlite +webm"

FTP_URI="ftp://ftp.mozilla.org/pub/firefox/releases/"
# More URIs appended below...
SRC_URI="http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz"

ASM_DEPEND=">=dev-lang/yasm-1.1"

# Mesa 7.10 needed for WebGL + bugfixes
RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.10
	>=dev-libs/nspr-4.8.8
	>=dev-libs/glib-2.26:2
	>=media-libs/mesa-7.10
	media-libs/libpng[apng]
	virtual/libffi
	system-sqlite? ( >=dev-db/sqlite-3.7.4[fts3,secure-delete,unlock-notify,debug=] )
	webm? ( media-libs/libvpx
		media-libs/alsa-lib )
	crashreporter? ( net-misc/curl )"
# We don't use PYTHON_DEPEND/PYTHON_USE_WITH for some silly reason
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	pgo? (
		=dev-lang/python-2*[sqlite]
		>=sys-devel/gcc-4.5 )
	webm? ( x86? ( ${ASM_DEPEND} )
		amd64? ( ${ASM_DEPEND} ) )"

# No source releases for alpha|beta
if [[ ${PV} =~ alpha ]]; then
	SRC_URI="${SRC_URI}
		http://dev.gentoo.org/~anarchy/mozilla/firefox/firefox-${FF_PV}_${CHANGESET}.source.tar.bz2"
	S="${WORKDIR}/mozilla-central"
elif [[ ${PV} =~ beta ]]; then
	SRC_URI="${SRC_URI}
		${FTP_URI}/${FF_PV}/source/firefox-${FF_PV}.source.tar.bz2"
	S="${WORKDIR}/mozilla-beta"
else
	SRC_URI="${SRC_URI}
		${FTP_URI}/${FF_PV}/source/firefox-${FF_PV}.source.tar.bz2"
	S="${WORKDIR}/mozilla-release"
fi

# No language packs for alphas
if ! [[ ${PV} =~ alpha|beta ]]; then
	# This list can be updated with scripts/get_langs.sh from mozilla overlay
	LANGS=(af ak ar ast be bg bn-BD bn-IN br bs ca cs cy da de el en en-GB en-US
	en-ZA eo es-AR es-CL es-ES es-MX et eu fa fi fr fy-NL ga-IE gd gl gu-IN he
	hi-IN hr hu hy-AM id is it ja kk kn ko ku lg lt lv mai mk ml mr nb-NO nl
	nn-NO nso or pa-IN pl pt-BR pt-PT rm ro ru si sk sl son sq sr sv-SE ta ta-LK
	te th tr uk vi zh-CN zh-TW zu)

	for X in "${LANGS[@]}" ; do
		# en and en_US are handled internally
		if [[ ${X} != en ]] && [[ ${X} != en-US ]]; then
			SRC_URI="${SRC_URI}
				linguas_${X/-/_}? ( ${FTP_URI}/${FF_PV}/linux-i686/xpi/${X}.xpi -> ${P}-${X}.xpi )"
		fi
		IUSE="${IUSE} linguas_${X/-/_}"
		# Install all the specific locale xpis if there's no generic locale xpi
		# Example: there's no pt.xpi, so install all pt-*.xpi
		if ! has ${X%%-*} "${LANGS[@]}"; then
			SRC_URI="${SRC_URI}
				linguas_${X%%-*}? ( ${FTP_URI}/${FF_PV}/linux-i686/xpi/${X}.xpi -> ${P}-${X}.xpi )"
			IUSE="${IUSE} linguas_${X%%-*}"
		fi
	done
fi

QA_PRESTRIPPED="usr/$(get_libdir)/${PN}/firefox"

# TODO: Move all the linguas crap to an eclass
linguas() {
	# Generate the list of language packs called "linguas"
	# This list is used to install the xpi language packs
	local LINGUA
	for LINGUA in ${LINGUAS}; do
		if has ${LINGUA} en en_US; then
			# For mozilla products, en and en_US are handled internally
			continue
		# If this language is supported by ${P},
		elif has ${LINGUA} "${LANGS[@]//-/_}"; then
			# Add the language to linguas, if it isn't already there
			has ${LINGUA//_/-} "${linguas[@]}" || linguas+=(${LINGUA//_/-})
			continue
		# For each short LINGUA that isn't in LANGS,
		# add *all* long LANGS to the linguas list
		elif ! has ${LINGUA%%-*} "${LANGS[@]}"; then
			for LANG in "${LANGS[@]}"; do
				if [[ ${LANG} == ${LINGUA}-* ]]; then
					has ${LANG} "${linguas[@]}" || linguas+=(${LANG})
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${P} does not support the ${LINGUA} locale"
	done
}

pkg_setup() {
	moz_pkgsetup

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XDG_SESSION_COOKIE \
		XAUTHORITY

	if ! use bindist; then
		einfo
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation"
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"
	fi

	if use pgo; then
		einfo
		ewarn "You will do a double build for profile guided optimization."
		ewarn "This will result in your build taking at least twice as long as before."
	fi
}

src_unpack() {
	unpack ${A}

	linguas
	for X in "${linguas[@]}"; do
		# FIXME: Add support for unpacking xpis to portage
		xpi_unpack "${P}-${X}.xpi"
	done
}

src_prepare() {
	# Apply our patches
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}/firefox"

	# Allow user to apply any additional patches without modifing ebuild
	epatch_user

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Disable gnomevfs extension
	sed -i -e "s:gnomevfs::" "${S}/"browser/confvars.sh \
		-e "s:gnomevfs::" "${S}/"xulrunner/confvars.sh \
		|| die "Failed to remove gnomevfs extension"

	# Ensure that are plugins dir is enabled as default
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/$(get_libdir)/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path!"

	# Fix sandbox violations during make clean, bug 372817
	sed -e "s:\(/no-such-file\):${T}\1:g" \
		-i "${S}"/config/rules.mk \
		-i "${S}"/js/src/config/rules.mk \
		-i "${S}"/nsprpub/configure{.in,} \
		|| die

	#Fix compilation with curl-7.21.7 bug 376027
	sed -e '/#include <curl\/types.h>/d'  \
		-i "${S}"/toolkit/crashreporter/google-breakpad/src/common/linux/http_upload.cc \
		-i "${S}"/toolkit/crashreporter/google-breakpad/src/common/linux/libcurl_wrapper.cc \
		-i "${S}"/config/system-headers \
		-i "${S}"/js/src/config/system-headers || die "Sed failed"

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

	mozconfig_annotate '' --prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --libdir="${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-gconf
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --enable-safe-browsing
	mozconfig_annotate '' --with-system-png
	mozconfig_annotate '' --enable-system-ffi

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}
	mozconfig_annotate '' --target="${CTARGET:-${CHOST}}"

	mozconfig_use_enable system-sqlite

	# Allow for a proper pgo build
	if use pgo; then
		echo "mk_add_options PROFILE_GEN_SCRIPT='\$(PYTHON) \$(OBJDIR)/_profile/pgo/profileserver.py'" >> "${S}"/.mozconfig
	fi

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	elif [[ $(gcc-major-version) -gt 4 || $(gcc-minor-version) -gt 3 ]]; then
		if use amd64 || use x86; then
			append-flags -mno-avx
		fi
	fi
}

src_compile() {
	if use pgo; then
		addpredict /root
		addpredict /etc/gconf
		# Firefox tries to dri stuff when it's run, see bug 380283
		shopt -s nullglob
		local cards=$(echo -n /dev/{dri,ati}/card* /dev/nvidiactl* | sed 's/ /:/g')
		shopt -u nullglob
		test -n "${cards}" && addpredict "${cards}"

		CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
		MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		Xemake -f client.mk profiledbuild || die "Xemake failed"
	else
		CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
		MOZ_MAKE_FLAGS="${MAKEOPTS}" \
		emake -f client.mk || die "emake failed"
	fi

}

src_install() {
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# MOZ_BUILD_ROOT, and hence OBJ_DIR change depending on arch, compiler, pgo, etc.
	local obj_dir="$(echo */config.log)"
	obj_dir="${obj_dir%/*}"
	cd "${S}/${obj_dir}"

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${S}/${obj_dir}"/dist/bin/xpcshell

	# Add our default prefs for firefox + xulrunner
	cp "${FILESDIR}"/gentoo-default-prefs.js \
		"${S}/${obj_dir}/dist/bin/defaults/pref/all-gentoo.js" || die

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake DESTDIR="${D}" install || die "emake install failed"

	linguas
	for X in "${linguas[@]}"; do
		xpi_install "${WORKDIR}/${P}-${X}"
	done

	local size sizes icon_path icon name
	if use bindist; then
		sizes="16 32 48"
		icon_path="${S}/browser/branding/unofficial"
		# Firefox's new rapid release cycle means no more codenames
		# Let's just stick with this one...
		icon="tumucumaque"
		name="Tumucumaque"
	else
		sizes="16 22 24 32 256"
		icon_path="${S}/browser/branding/official"
		icon="${PN}"
		name="Mozilla Firefox"
	fi

	# Install icons and .desktop for menu entry
	for size in ${sizes}; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png" || die
	done
	# The 128x128 icon has a different name
	insinto "/usr/share/icons/hicolor/128x128/apps"
	newins "${icon_path}/mozicon128.png" "${icon}.png" || die
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${icon_path}/content/icon48.png" "${icon}.png" || die
	newmenu "${FILESDIR}/icon/${PN}.desktop" "${PN}.desktop" || die
	sed -i -e "s:@NAME@:${name}:" -e "s:@ICON@:${icon}:" \
		"${ED}/usr/share/applications/${PN}.desktop" || die

	# Add StartupNotify=true bug 237317
	if use startup-notification ; then
		echo "StartupNotify=true" >> "${ED}/usr/share/applications/${PN}.desktop"
	fi

	# Required in order to use plugins and even run firefox on hardened.
	pax-mark m "${ED}"/${MOZILLA_FIVE_HOME}/{firefox,firefox-bin,plugin-container}

	# Plugins dir
	dosym ../nsbrowser/plugins "${MOZILLA_FIVE_HOME}"/plugins \
		|| die "failed to symlink"

	# very ugly hack to make firefox not sigbus on sparc
	# FIXME: is this still needed??
	use sparc && { sed -e 's/Firefox/FirefoxGentoo/g' \
					 -i "${ED}/${MOZILLA_FIVE_HOME}/application.ini" || \
					 die "sparc sed failed"; }
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
