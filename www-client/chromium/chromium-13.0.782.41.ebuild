# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-13.0.782.41.ebuild,v 1.1 2011/06/30 10:27:45 phajdan.jr Exp $

EAPI="3"
PYTHON_DEPEND="2:2.6"

inherit eutils fdo-mime flag-o-matic gnome2-utils linux-info multilib \
	pax-utils portability python toolchain-funcs versionator virtualx

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
SRC_URI="http://build.chromium.org/official/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cups gnome gnome-keyring kerberos xinerama"

# en_US is ommitted on purpose from the list below. It must always be available.
LANGS="am ar bg bn ca cs da de el en_GB es es_LA et fa fi fil fr gu he hi hr
hu id it ja kn ko lt lv ml mr nb nl pl pt_BR pt_PT ro ru sk sl sr sv sw ta te th
tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

RDEPEND="app-arch/bzip2
	dev-libs/dbus-glib
	>=dev-libs/icu-4.4.1
	>=dev-libs/libevent-1.4.13
	dev-libs/libxml2[icu]
	dev-libs/libxslt
	>=dev-libs/nss-3.12.3
	gnome? ( >=gnome-base/gconf-2.24.0 )
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.28.2 )
	>=media-libs/alsa-lib-1.0.19
	media-libs/flac
	virtual/jpeg
	media-libs/libpng
	>=media-libs/libvpx-0.9.5
	>=media-libs/libwebp-0.1.2
	media-libs/speex
	cups? ( >=net-print/cups-1.3.11 )
	sys-libs/zlib
	x11-libs/gtk+:2
	x11-libs/libXScrnSaver
	x11-libs/libXtst"
DEPEND="${RDEPEND}
	dev-lang/perl
	dev-lang/yasm
	>=dev-util/gperf-3.0.3
	>=dev-util/pkgconfig-0.23
	sys-devel/flex
	>=sys-devel/make-3.81-r2
	x11-libs/libXinerama
	test? (
		dev-python/pyftpdlib
		dev-python/simplejson
		virtual/krb5
	)"
RDEPEND+="
	kerberos? ( virtual/krb5 )
	xinerama? ( x11-libs/libXinerama )
	x11-misc/xdg-utils
	virtual/ttf-fonts"

gyp_use() {
	if [[ $# -lt 2 ]]; then
		echo "!!! usage: gyp_use <USEFLAG> <GYPFLAG>" >&2
		return 1
	fi
	if use "$1"; then echo "-D$2=1"; else echo "-D$2=0"; fi
}

egyp() {
	set -- build/gyp_chromium --depth=. "${@}"
	echo "${@}" >&2
	"${@}"
}

# Chromium uses different names for some langs,
# return Chromium name corresponding to a Gentoo lang.
chromium_lang() {
	if [[ "$1" == "es_LA" ]]; then
		echo "es_419"
	else
		echo "$1"
	fi
}

pkg_setup() {
	CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"

	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX RANLIB

	# Make sure the build system will use the right python, bug #344367.
	python_set_active_version 2
	python_pkg_setup

	# Prevent user problems like bug #348235.
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		ewarn "You have enabled debug info (probably have -g or -ggdb in your \$C{,XX}FLAGS)."
		ewarn "You may experience really long compilation times and/or increased memory usage."
		ewarn "If compilation fails, please try removing -g{,gdb} before reporting a bug."
	fi
	eshopts_pop

	# Warn if the kernel doesn't support features useful for sandboxing,
	# bug #363907.
	CONFIG_CHECK="~PID_NS ~NET_NS"
	check_extra_config
}

src_prepare() {

	# Add Sabayon User Agent to browser string
	epatch "${FILESDIR}"/${PN}-sabayon-user-agent-11.0.x.patch

	# Make sure we don't use bundled libvpx headers.
	epatch "${FILESDIR}/${PN}-system-vpx-r4.patch"

	# Backport build fix for perl-5.14, bug #372301.
	epatch "${FILESDIR}/${PN}-perl-5.14-r0.patch"

	# Backport build fix for glibc-2.14, bug #372495.
	epatch "${FILESDIR}/${PN}-glibc-2.14-r0.patch"

	# Fix build without libgcrypt, bug #373079.
	epatch "${FILESDIR}/${PN}-libgcrypt-r0.patch"

	# Remove most bundled libraries. Some are still needed.
	find third_party -type f \! -iname '*.gyp*' \
		\! -path 'third_party/WebKit/*' \
		\! -path 'third_party/angle/*' \
		\! -path 'third_party/cacheinvalidation/*' \
		\! -path 'third_party/cld/*' \
		\! -path 'third_party/expat/*' \
		\! -path 'third_party/ffmpeg/*' \
		\! -path 'third_party/flac/flac.h' \
		\! -path 'third_party/gpsd/*' \
		\! -path 'third_party/harfbuzz/*' \
		\! -path 'third_party/hunspell/*' \
		\! -path 'third_party/iccjpeg/*' \
		\! -path 'third_party/launchpad_translations/*' \
		\! -path 'third_party/leveldb/*' \
		\! -path 'third_party/libjingle/*' \
		\! -path 'third_party/libphonenumber/*' \
		\! -path 'third_party/libvpx/libvpx.h' \
		\! -path 'third_party/mesa/*' \
		\! -path 'third_party/modp_b64/*' \
		\! -path 'third_party/npapi/*' \
		\! -path 'third_party/openmax/*' \
		\! -path 'third_party/ots/*' \
		\! -path 'third_party/protobuf/*' \
		\! -path 'third_party/skia/*' \
		\! -path 'third_party/speex/speex.h' \
		\! -path 'third_party/sqlite/*' \
		\! -path 'third_party/tcmalloc/*' \
		\! -path 'third_party/tlslite/*' \
		\! -path 'third_party/undoview/*' \
		\! -path 'third_party/zlib/contrib/minizip/*' \
		-delete || die

	# Make sure the build system will use the right python, bug #344367.
	# Only convert directories that need it, to save time.
	python_convert_shebangs -q -r 2 build tools
}

src_configure() {
	local myconf=""

	# Never tell the build system to "enable" SSE2, it has a few unexpected
	# additions, bug #336871.
	myconf+=" -Ddisable_sse2=1"

	# Use system-provided libraries.
	# TODO: use_system_ffmpeg (bug #71931). That makes yasm unneeded.
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_ssl (http://crbug.com/58087).
	# TODO: use_system_sqlite (http://crbug.com/22208).
	myconf+="
		-Duse_system_bzip2=1
		-Duse_system_flac=1
		-Duse_system_icu=1
		-Duse_system_libevent=1
		-Duse_system_libjpeg=1
		-Duse_system_libpng=1
		-Duse_system_libwebp=1
		-Duse_system_libxml=1
		-Duse_system_speex=1
		-Duse_system_vpx=1
		-Duse_system_xdg_utils=1
		-Duse_system_yasm=1
		-Duse_system_zlib=1"

	# Optional dependencies.
	myconf+="
		$(gyp_use cups use_cups)
		$(gyp_use gnome use_gconf)
		$(gyp_use gnome-keyring use_gnome_keyring)
		$(gyp_use gnome-keyring linux_link_gnome_keyring)"

	# Enable sandbox.
	myconf+="
		-Dlinux_sandbox_path=${CHROMIUM_HOME}/chrome_sandbox
		-Dlinux_sandbox_chrome_path=${CHROMIUM_HOME}/chrome"

	if host-is-pax; then
		# Prevent the build from failing (bug #301880). The performance
		# difference is very small.
		myconf+=" -Dv8_use_snapshot=0"
	fi

	# Our system ffmpeg should support more codecs than the bundled one
	# for Chromium.
	# TODO: uncomment when bug #371931 is fixed.
	# myconf+=" -Dproprietary_codecs=1"

	local myarch="$(tc-arch)"
	if [[ $myarch = amd64 ]] ; then
		myconf+=" -Dtarget_arch=x64"
	elif [[ $myarch = x86 ]] ; then
		myconf+=" -Dtarget_arch=ia32"
	elif [[ $myarch = arm ]] ; then
		# TODO: check this again after
		# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=39509 is fixed.
		append-flags -fno-tree-sink

		myconf+=" -Dtarget_arch=arm -Ddisable_nacl=1 -Dlinux_use_tcmalloc=0"
	else
		die "Failed to determine target arch, got '$myarch'."
	fi

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf+=" -Dwerror="

	# Avoid a build error with -Os, bug #352457.
	replace-flags "-Os" "-O2"

	egyp ${myconf} || die
}

src_compile() {
	emake chrome chrome_sandbox BUILDTYPE=Release V=1 || die
	pax-mark m out/Release/chrome
	if use test; then
		emake {base,crypto,googleurl,net}_unittests BUILDTYPE=Release V=1 || die
		pax-mark m out/Release/{base,crypto,googleurl,net}_unittests
	fi
}

src_test() {
	# For more info see bug #350349.
	local mylocale='en_US.utf8'
	if ! locale -a | grep -q "$mylocale"; then
		eerror "${PN} requires ${mylocale} locale for tests"
		eerror "Please read the following guides for more information:"
		eerror "  http://www.gentoo.org/doc/en/guide-localization.xml"
		eerror "  http://www.gentoo.org/doc/en/utf-8.xml"
		die "locale ${mylocale} is not supported"
	fi

	# For more info see bug #370957.
	if [[ $UID -eq 0 ]]; then
		die "Tests must be run as non-root. Please use FEATURES=userpriv."
	fi

	# For more info see bug #350347.
	LC_ALL="${mylocale}" VIRTUALX_COMMAND=out/Release/base_unittests virtualmake \
		'--gtest_filter=-ICUStringConversionsTest.*'

	LC_ALL="${mylocale}" VIRTUALX_COMMAND=out/Release/crypto_unittests virtualmake
	LC_ALL="${mylocale}" VIRTUALX_COMMAND=out/Release/googleurl_unittests virtualmake

	# NetUtilTest: bug #361885.
	# UDP: unstable, active development. We should revisit this later.
	LC_ALL="${mylocale}" VIRTUALX_COMMAND=out/Release/net_unittests virtualmake \
		'--gtest_filter=-NetUtilTest.IDNToUnicode*:NetUtilTest.FormatUrl*:*UDP*'
}

src_install() {
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome
	doexe out/Release/chrome_sandbox || die
	fperms 4755 "${CHROMIUM_HOME}/chrome_sandbox"

	insinto "${CHROMIUM_HOME}"
	doins out/Release/libppGoogleNaClPluginChrome.so || die

	newexe "${FILESDIR}"/chromium-launcher-r2.sh chromium-launcher.sh || die

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it; bug #355517.
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser || die
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium || die

	# Allow users to override command-line options, bug #357629.
	dodir /etc/chromium || die
	insinto /etc/chromium
	newins "${FILESDIR}/chromium.default" "default" || die

	# Support LINGUAS, bug #332751.
	local pak
	for pak in out/Release/locales/*.pak; do
		local pakbasename="$(basename ${pak})"
		local pakname="${pakbasename%.pak}"
		local langname="${pakname//-/_}"

		# Do not issue warning for en_US locale. This is the fallback
		# locale so it should always be installed.
		if [[ "${langname}" == "en_US" ]]; then
			continue
		fi

		local found=false
		local lang
		for lang in ${LANGS}; do
			local crlang="$(chromium_lang ${lang})"
			if [[ "${langname}" == "${crlang}" ]]; then
				found=true
				break
			fi
		done
		if ! $found; then
			ewarn "LINGUAS warning: no ${langname} in LANGS"
		fi
	done
	local lang
	for lang in ${LANGS}; do
		local crlang="$(chromium_lang ${lang})"
		local pakfile="out/Release/locales/${crlang//_/-}.pak"
		if [ ! -f "${pakfile}" ]; then
			ewarn "LINGUAS warning: no .pak file for ${lang} (${pakfile} not found)"
		fi
		if ! use linguas_${lang}; then
			rm "${pakfile}" || die
		fi
	done

	insinto "${CHROMIUM_HOME}"
	doins out/Release/chrome.pak || die
	doins out/Release/resources.pak || die

	doins -r out/Release/locales || die
	doins -r out/Release/resources || die

	newman out/Release/chrome.1 chromium.1 || die
	newman out/Release/chrome.1 chromium-browser.1 || die

	# Chromium looks for these in its folder
	# See media_posix.cc and base_paths_linux.cc
	# TODO: uncomment when bug #371931 is fixed.
	#dosym /usr/$(get_libdir)/libavcodec.so.52 "${CHROMIUM_HOME}" || die
	#dosym /usr/$(get_libdir)/libavformat.so.52 "${CHROMIUM_HOME}" || die
	#dosym /usr/$(get_libdir)/libavutil.so.50 "${CHROMIUM_HOME}" || die
	doexe out/Release/ffmpegsumo_nolink || die
	doexe out/Release/libffmpegsumo.so || die

	# Install icons and desktop entry.
	for SIZE in 16 22 24 32 48 64 128 256 ; do
		insinto /usr/share/icons/hicolor/${SIZE}x${SIZE}/apps
		newins chrome/app/theme/chromium/product_logo_${SIZE}.png \
			chromium-browser.png || die
	done
	local mime_types="text/html;text/xml;application/xhtml+xml;"
	mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # bug #360797
	make_desktop_entry chromium-browser "Chromium" chromium-browser \
		"Network;WebBrowser" "MimeType=${mime_types}"
	sed -e "/^Exec/s/$/ %U/" -i "${D}"/usr/share/applications/*.desktop || die

	# Install GNOME default application entry (bug #303100).
	if use gnome; then
		dodir /usr/share/gnome-control-center/default-apps || die
		insinto /usr/share/gnome-control-center/default-apps
		doins "${FILESDIR}"/chromium-browser.xml || die
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update

	# For more info see bug #292201, bug #352263, bug #361859.
	elog
	elog "Depending on your desktop environment, you may need"
	elog "to install additional packages to get icons on the Downloads page."
	elog
	elog "For KDE, the required package is kde-base/oxygen-icons."
	elog
	elog "For other desktop environments, try one of the following:"
	elog " - x11-themes/gnome-icon-theme"
	elog " - x11-themes/tango-icon-theme"

	# For more info see bug #359153.
	elog
	elog "Some web pages may require additional fonts to display properly."
	elog "Try installing some of the following packages if some characters"
	elog "are not displayed properly:"
	elog " - media-fonts/arphicfonts"
	elog " - media-fonts/bitstream-cyberbit"
	elog " - media-fonts/droid"
	elog " - media-fonts/ipamonafont"
	elog " - media-fonts/ja-ipafonts"
	elog " - media-fonts/takao-fonts"
	elog " - media-fonts/wqy-microhei"
	elog " - media-fonts/wqy-zenhei"
}

pkg_postrm() {
	gnome2_icon_cache_update
}
