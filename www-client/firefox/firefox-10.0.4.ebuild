# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/firefox/firefox-10.0.4.ebuild,v 1.7 2012/05/26 17:18:00 armin76 Exp $

EAPI="3"
VIRTUALX_REQUIRED="pgo"
WANT_AUTOCONF="2.1"
MOZ_ESR="1"

# This list can be updated with scripts/get_langs.sh from the mozilla overlay
MOZ_LANGS=(af ak ar as ast be bg bn-BD bn-IN br bs ca cs csb cy da de el en
en-GB en-US en-ZA eo es-AR es-CL es-ES es-MX et eu fa fi fr fy-NL ga-IE gd gl
gu-IN he hi-IN hr hu hy-AM id is it ja kk kn ko ku lg lt lv mai mk ml mr nb-NO
nl nn-NO nso or pa-IN pl pt-BR pt-PT rm ro ru si sk sl son sq sr sv-SE ta ta-LK
te th tr uk vi zh-CN zh-TW zu)

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_alpha/a}" # Handle alpha for SRC_URI
MOZ_PV="${MOZ_PV/_beta/b}" # Handle beta for SRC_URI
MOZ_PV="${MOZ_PV/_rc/rc}" # Handle rc for SRC_URI

if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly version numbers
	MOZ_PV="${MOZ_PV}esr"
fi

# Changeset for alpha snapshot
CHANGESET="e56ecd8b3a68"
# Patch version
PATCH="${PN}-10.0-patches-0.8"
# Upstream ftp release URI that's used by mozlinguas.eclass
# We don't use the http mirror because it deletes old tarballs.
MOZ_FTP_URI="ftp://ftp.mozilla.org/pub/${PN}/releases/"

inherit check-reqs flag-o-matic toolchain-funcs eutils gnome2-utils mozconfig-3 multilib pax-utils fdo-mime autotools python virtualx nsplugins mozlinguas

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.com/firefox"

KEYWORDS="alpha amd64 ~arm ~hppa ia64 ~ppc ~ppc64 -sparc x86 ~amd64-linux ~x86-linux"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="bindist +crashreporter +ipc +minimal neon pgo selinux system-sqlite +webm"

# More URIs appended below...
SRC_URI="${SRC_URI}
	http://dev.gentoo.org/~anarchy/mozilla/patchsets/${PATCH}.tar.xz"

ASM_DEPEND=">=dev-lang/yasm-1.1"

# Mesa 7.10 needed for WebGL + bugfixes
RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.13.1
	>=dev-libs/nspr-4.8.8
	>=dev-libs/glib-2.26:2
	>=media-libs/mesa-7.10
	media-libs/libpng[apng]
	virtual/libffi
	system-sqlite? ( >=dev-db/sqlite-3.7.7.1[fts3,secure-delete,threadsafe,unlock-notify,debug=] )
	webm? ( >=media-libs/libvpx-1.0.0
		media-libs/alsa-lib )
	crashreporter? ( net-misc/curl )
	selinux? ( sec-policy/selinux-mozilla )"
# We don't use PYTHON_DEPEND/PYTHON_USE_WITH for some silly reason
DEPEND="${RDEPEND}
	virtual/pkgconfig
	pgo? (
		=dev-lang/python-2*[sqlite]
		>=sys-devel/gcc-4.5 )
	webm? ( virtual/opengl
		x86? ( ${ASM_DEPEND} )
		amd64? ( ${ASM_DEPEND} ) )"

# No source releases for alpha|beta
if [[ ${PV} =~ alpha ]]; then
	SRC_URI="${SRC_URI}
		http://dev.gentoo.org/~anarchy/mozilla/firefox/firefox-${MOZ_PV}_${CHANGESET}.source.tar.bz2"
	S="${WORKDIR}/mozilla-central"
elif [[ ${PV} =~ beta ]]; then
	SRC_URI="${SRC_URI}
		${MOZ_FTP_URI}/${MOZ_PV}/source/firefox-${MOZ_PV}.source.tar.bz2"
	S="${WORKDIR}/mozilla-beta"
else
	SRC_URI="${SRC_URI}
		${MOZ_FTP_URI}/${MOZ_PV}/source/firefox-${MOZ_PV}.source.tar.bz2"
	if [[ ${MOZ_ESR} == 1 ]]; then
		S="${WORKDIR}/mozilla-esr${PV%%.*}"
	else
		S="${WORKDIR}/mozilla-release"
	fi
fi

QA_PRESTRIPPED="usr/$(get_libdir)/${PN}/firefox"

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
		elog "You are enabling official branding. Manually check configuration"
		elog "carefully to ensure compliance with licensing provisions"
		elog "of the Mozilla Foundation if you are re-distributing this package."
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag"
	fi

	if use pgo; then
		einfo
		ewarn "You will do a double build for profile guided optimization."
		ewarn "This will result in your build taking at least twice as long as before."
	fi

	# Ensure we have enough disk space to compile
	if use pgo || use debug || use test ; then
		CHECKREQS_DISK_BUILD="8G"
	else
		CHECKREQS_DISK_BUILD="4G"
	fi
	check-reqs_pkg_setup
}

src_unpack() {
	unpack ${A}

	# Unpack language packs
	mozlinguas_src_unpack
}

src_prepare() {
	# Apply our patches
	EPATCH_EXCLUDE="6012_fix_shlibsign.patch" \
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}/firefox"

	# Allow user to apply any additional patches without modifing ebuild
	epatch_user

	# NEON (ARM SIMD) support is broken in Firefox at linker level
	# undefined symbol arm_private::neon_enabled
	# Upstream should really take care of it, since compilation
	# fails on ARMv7.
	# So, here we force it on and off getting rid of the fugly
	# macro hackery.
	# Besides this, emerge via qemu-user fails if USE=neon
	# due to unsupported instruction set at src_install (xpcshell)
	if use arm && use neon; then
		einfo "Enabling NEON SIMD"
		# HAVE_ARM_NEON=1 should be actually set by
		# configure basing on compiler support
		append-cppflags "-DMOZILLA_PRESUME_NEON"
	elif use arm && ! use neon; then
		einfo "Disabling NEON SIMD"
		# eautoreconf is called below
		for conf in "${S}"/configure.in "${S}"/js/src/configure.in; do
			sed -i "s:AC_DEFINE(HAVE_ARM_NEON)::" "${conf}" \
				|| die "cannot turn off NEON (AC_DEFINE)"
			sed -i "s:HAVE_ARM_NEON=1:true:" "${conf}" \
				|| die "cannot turn off NEON (HAVE_ARM_NEON)"
		done
	fi

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
	# Taken from Debian
	use arm && mozconfig_annotate '' --disable-methodjit
	use arm && append-cflags "-D__ARM_PCS"

	# Other ff-specific settings
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}
	mozconfig_annotate '' --target="${CTARGET:-${CHOST}}"

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
		# Reset and cleanup environment variables used by GNOME/XDG
		gnome2_environment_reset

		# Firefox tries to use dri stuff when it's run, see bug 380283
		shopt -s nullglob
		cards=$(echo -n /dev/dri/card* | sed 's/ /:/g')
		if test -n "${cards}"; then
			# FOSS drivers are fine
			addpredict "${cards}"
		else
			cards=$(echo -n /dev/ati/card* /dev/nvidiactl* | sed 's/ /:/g')
			if test -n "${cards}"; then
				# Binary drivers seem to cause access violations anyway, so
				# let's use indirect rendering so that the device files aren't
				# touched at all. See bug 394715.
				export LIBGL_ALWAYS_INDIRECT=1
			fi
		fi
		shopt -u nullglob

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
	cp "${FILESDIR}"/gentoo-default-prefs.js-1 \
		"${S}/${obj_dir}/dist/bin/defaults/pref/all-gentoo.js" || die

	MOZ_MAKE_FLAGS="${MAKEOPTS}" \
	emake DESTDIR="${D}" install || die "emake install failed"

	# Install language packs
	mozlinguas_src_install

	local size sizes icon_path icon name
	if use bindist; then
		sizes="16 32 48"
		icon_path="${S}/browser/branding/aurora"
		# Firefox's new rapid release cycle means no more codenames
		# Let's just stick with this one...
		icon="aurora"
		name="Aurora"
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
	pax-mark m "${ED}"${MOZILLA_FIVE_HOME}/{firefox,firefox-bin,plugin-container}

	# Plugins dir
	share_plugins_dir

	if use minimal; then
		rm -rf "${ED}"/usr/include "${ED}${MOZILLA_FIVE_HOME}"/{idl,include,lib,sdk} || \
			die "Failed to remove sdk and headers"
	fi

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
