# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-9.0.597.45.ebuild,v 1.1 2011/01/07 08:28:34 phajdan.jr Exp $

EAPI="3"
PYTHON_DEPEND="2:2.6"

inherit eutils flag-o-matic multilib pax-utils portability python \
	toolchain-funcs versionator

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
SRC_URI="http://build.chromium.org/buildbot/official/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cups +gecko-mediaplayer gnome gnome-keyring system-sqlite system-v8"

RDEPEND="app-arch/bzip2
	system-sqlite? (
		>=dev-db/sqlite-3.6.23.1[fts3,icu,secure-delete,threadsafe]
	)
	system-v8? ( =dev-lang/v8-2.5.9.7 )
	dev-libs/dbus-glib
	>=dev-libs/icu-4.4.1
	>=dev-libs/libevent-1.4.13
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-libs/nss-3.12.3
	gnome? ( >=gnome-base/gconf-2.24.0 )
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.28.2 )
	>=media-libs/alsa-lib-1.0.19
	virtual/jpeg
	media-libs/libpng
	media-libs/libvpx
	>=media-video/ffmpeg-0.6_p25767[threads]
	cups? ( >=net-print/cups-1.3.11 )
	sys-libs/zlib
	>=x11-libs/gtk+-2.14.7
	x11-libs/libXScrnSaver
	x11-libs/libXtst"
DEPEND="${RDEPEND}
	dev-lang/perl
	>=dev-util/chromium-tools-0.1.4
	>=dev-util/gperf-3.0.3
	>=dev-util/pkgconfig-0.23
	sys-devel/flex"
RDEPEND+="
	|| (
		x11-themes/gnome-icon-theme
		x11-themes/oxygen-molecule
		x11-themes/tango-icon-theme
		x11-themes/xfce4-icon-theme
	)
	x11-misc/xdg-utils
	virtual/ttf-fonts
	gecko-mediaplayer? ( !www-plugins/gecko-mediaplayer[gnome] )"

egyp() {
	set -- build/gyp_chromium --depth=. "${@}"
	echo "${@}" >&2
	"${@}"
}

get_installed_v8_version() {
	best_version dev-lang/v8 | sed -e 's@dev-lang/v8-@@g'
}

remove_bundled_lib() {
	local out
	out="$(find $1 -type f \! -iname '*.gyp' -print -delete)" \
		|| die "failed to remove bundled library $1"
	if [[ -z $out ]]; then
		die "no files matched when removing bundled library $1"
	fi
}

pkg_setup() {
	CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"

	# Make sure the build system will use the right tools, bug #340795.
	tc-export AR CC CXX RANLIB

	# Make sure the build system will use the right python, bug #344367.
	python_set_active_version 2
	python_pkg_setup

	# Prevent user problems like bug #299777.
	if ! grep -q /dev/shm <<< $(get_mounts); then
		ewarn "You don't have tmpfs mounted at /dev/shm."
		ewarn "${PN} may fail to start in that configuration."
		ewarn "Please uncomment the /dev/shm entry in /etc/fstab,"
		ewarn "and run 'mount /dev/shm'."
	fi
	if [ `stat -c %a /dev/shm` -ne 1777 ]; then
		ewarn "/dev/shm does not have correct permissions."
		ewarn "${PN} may fail to start in that configuration."
		ewarn "Please run 'chmod 1777 /dev/shm'."
	fi
}

src_prepare() {

	# Add Sabayon User Agent to browser string
	epatch "${FILESDIR}"/${PN}-sabayon-user-agent-7.0.x.patch

	# Enable optional support for gecko-mediaplayer.
	epatch "${FILESDIR}"/${PN}-gecko-mediaplayer-r0.patch

	# Make sure we don't use bundled libvpx headers.
	epatch "${FILESDIR}"/${PN}-system-vpx-r1.patch

	# Small fixes to make tests compile, to be upstreamed.
	epatch "${FILESDIR}"/${PN}-tests-r0.patch

	remove_bundled_lib "third_party/bzip2"
	remove_bundled_lib "third_party/codesighs"
	remove_bundled_lib "third_party/icu"
	remove_bundled_lib "third_party/jemalloc"
	remove_bundled_lib "third_party/lcov"
	remove_bundled_lib "third_party/libevent"
	remove_bundled_lib "third_party/libjpeg"
	remove_bundled_lib "third_party/libpng"
	remove_bundled_lib "third_party/libvpx"
	remove_bundled_lib "third_party/libxml"
	remove_bundled_lib "third_party/libxslt"
	remove_bundled_lib "third_party/lzma_sdk"
	remove_bundled_lib "third_party/molokocacao"
	remove_bundled_lib "third_party/ocmock"
	remove_bundled_lib "third_party/yasm"
	# TODO: also remove third_party/ffmpeg (needs to be compile-tested).
	# TODO: also remove third_party/zlib. For now the compilation fails if we
	# remove it (minizip-related).

	local v8_bundled="$(v8-extract-version v8/src/version.cc)"
	if use system-v8; then
		local v8_installed="$(get_installed_v8_version)"
		einfo "V8 version: bundled - ${v8_bundled}; installed - ${v8_installed}"
		version_is_at_least "${v8_bundled}" "${v8_installed}" || die
	else
		einfo "Bundled V8 version: ${v8_bundled}"
	fi

	if use system-sqlite; then
		remove_bundled_lib "third_party/sqlite/src"
		remove_bundled_lib "third_party/sqlite/preprocessed"
	fi

	if use system-v8; then
		# Provide our own gyp file that links with the system v8.
		# TODO: move this upstream.
		cp "${FILESDIR}"/v8.gyp v8/tools/gyp || die

		remove_bundled_lib "v8"

		# The implementation files include v8 headers with full path,
		# like #include "v8/include/v8.h". Make sure the system headers
		# will be used.
		# TODO: find a solution that can be upstreamed.
		rmdir v8/include || die
		ln -s /usr/include v8/include || die
	fi

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
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_ssl (need to consult upstream).
	myconf+="
		-Duse_system_bzip2=1
		-Duse_system_ffmpeg=1
		-Duse_system_icu=1
		-Duse_system_libevent=1
		-Duse_system_libjpeg=1
		-Duse_system_libpng=1
		-Duse_system_libxml=1
		-Duse_system_vpx=1
		-Duse_system_zlib=1"

	if use system-sqlite; then
		myconf+=" -Duse_system_sqlite=1"
	fi

	# The dependency on cups is optional, see bug #324105.
	if use cups; then
		myconf+=" -Duse_cups=1"
	else
		myconf+=" -Duse_cups=0"
	fi

	# Make GConf dependency optional, http://crbug.com/13322.
	if use gnome; then
		myconf+=" -Duse_gconf=1"
	else
		myconf+=" -Duse_gconf=0"
	fi

	if use "gnome-keyring"; then
		myconf+=" -Duse_gnome_keyring=1 -Dlinux_link_gnome_keyring=1"
	else
		# TODO: we should also disable code trying to dlopen
		# gnome-keyring in that case.
		myconf+=" -Duse_gnome_keyring=0 -Dlinux_link_gnome_keyring=0"
	fi

	# Enable sandbox.
	myconf+="
		-Dlinux_sandbox_path=${CHROMIUM_HOME}/chrome_sandbox
		-Dlinux_sandbox_chrome_path=${CHROMIUM_HOME}/chrome"

	if host-is-pax; then
		# Prevent the build from failing (bug #301880). The performance
		# difference is very small.
		myconf+=" -Dv8_use_snapshot=0"
	fi

	if use gecko-mediaplayer; then
		# Disable hardcoded blacklist for gecko-mediaplayer.
		# When www-plugins/gecko-mediaplayer is compiled with USE=gnome, it causes
		# the browser to hang. We can handle the situation via dependencies,
		# thus making it possible to use gecko-mediaplayer.
		append-flags -DGENTOO_CHROMIUM_ENABLE_GECKO_MEDIAPLAYER
	fi

	# Our system ffmpeg should support more codecs than the bundled one
	# for Chromium.
	myconf+=" -Dproprietary_codecs=1"

	# Use target arch detection logic from bug #296917.
	local myarch="$ABI"
	[[ $myarch = "" ]] && myarch="$ARCH"

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

	egyp ${myconf} || die
}

src_compile() {
	emake chrome chrome_sandbox BUILDTYPE=Release V=1 || die
	pax-mark m out/Release/chrome
}

src_install() {
	exeinto "${CHROMIUM_HOME}"
	doexe out/Release/chrome
	doexe out/Release/chrome_sandbox || die
	fperms 4755 "${CHROMIUM_HOME}/chrome_sandbox"
	doexe out/Release/xdg-settings || die
	doexe "${FILESDIR}"/chromium-launcher.sh || die

	insinto "${CHROMIUM_HOME}"
	doins out/Release/chrome.pak || die
	doins out/Release/resources.pak || die

	doins -r out/Release/locales || die
	doins -r out/Release/resources || die

	# chrome.1 is for chromium --help
	newman out/Release/chrome.1 chrome.1 || die
	newman out/Release/chrome.1 chromium.1 || die

	# Chromium looks for these in its folder
	# See media_posix.cc and base_paths_linux.cc
	dosym /usr/$(get_libdir)/libavcodec.so.52 "${CHROMIUM_HOME}" || die
	dosym /usr/$(get_libdir)/libavformat.so.52 "${CHROMIUM_HOME}" || die
	dosym /usr/$(get_libdir)/libavutil.so.50 "${CHROMIUM_HOME}" || die

	# Install icon and desktop entry.
	newicon out/Release/product_logo_48.png ${PN}-browser.png || die
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium || die
	make_desktop_entry chromium "Chromium" ${PN}-browser "Network;WebBrowser" \
		"MimeType=text/html;text/xml;application/xhtml+xml;"
	sed -e "/^Exec/s/$/ %U/" -i "${D}"/usr/share/applications/*.desktop || die

	# Install GNOME default application entry (bug #303100).
	if use gnome; then
		dodir /usr/share/gnome-control-center/default-apps || die
		insinto /usr/share/gnome-control-center/default-apps
		doins "${FILESDIR}"/chromium.xml || die
	fi
}
