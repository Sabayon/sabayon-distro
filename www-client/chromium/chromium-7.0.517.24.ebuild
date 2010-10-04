# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-7.0.517.24.ebuild,v 1.1 2010/09/29 09:54:08 phajdan.jr Exp $

EAPI="2"

inherit eutils flag-o-matic multilib pax-utils toolchain-funcs

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
SRC_URI="http://build.chromium.org/buildbot/official/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="cups gnome gnome-keyring"

RDEPEND="app-arch/bzip2
	>=dev-libs/icu-4.4.1
	>=dev-libs/libevent-1.4.13
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-libs/nss-3.12.3
	>=gnome-base/gconf-2.24.0
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.28.2 )
	>=media-libs/alsa-lib-1.0.19
	media-libs/jpeg:0
	media-libs/libpng
	cups? ( >=net-print/cups-1.4.4 )
	sys-libs/zlib
	>=x11-libs/gtk+-2.14.7
	x11-libs/libXScrnSaver"
DEPEND="${RDEPEND}
	dev-lang/perl
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
	x11-apps/xmessage
	x11-misc/xdg-utils
	virtual/ttf-fonts"

remove_bundled_lib() {
	einfo "Removing bundled library $1 ..."
	local out
	out="$(find $1 -mindepth 1 \! -iname '*.gyp' -print -delete)" \
		|| die "failed to remove bundled library $1"
	if [[ -z $out ]]; then
		die "no files matched when removing bundled library $1"
	fi
}

pkg_setup() {
	CHROMIUM_HOME="/usr/$(get_libdir)/chromium-browser"
}

src_prepare() {
	# Add Sabayon User Agent to browser string
	epatch "${FILESDIR}"/${PN}-sabayon-user-agent-7.0.x.patch

	# Add Gentoo plugin paths.
	epatch "${FILESDIR}"/${PN}-plugins-path-r0.patch

	# Make compile-time dependency on gnome-keyring optional, bug #332411.
	epatch "${FILESDIR}"/${PN}-gnome-keyring-r0.patch

	remove_bundled_lib "third_party/bzip2"
	remove_bundled_lib "third_party/codesighs"
	remove_bundled_lib "third_party/cros"
	remove_bundled_lib "third_party/icu"
	remove_bundled_lib "third_party/jemalloc"
	remove_bundled_lib "third_party/lcov"
	remove_bundled_lib "third_party/libevent"
	remove_bundled_lib "third_party/libjpeg"
	remove_bundled_lib "third_party/libpng"
	remove_bundled_lib "third_party/libxml"
	remove_bundled_lib "third_party/libxslt"
	remove_bundled_lib "third_party/lzma_sdk"
	remove_bundled_lib "third_party/molokocacao"
	remove_bundled_lib "third_party/ocmock"
	remove_bundled_lib "third_party/pyftpdlib"
	remove_bundled_lib "third_party/simplejson"
	remove_bundled_lib "third_party/tlslite"
	# TODO: also remove third_party/zlib. For now the compilation fails if we
	# remove it (minizip-related).
}

src_configure() {
	local myconf=""

	# Never tell the build system to "enable" SSE2, it has a few unexpected
	# additions, bug #336871.
	myconf+=" -Ddisable_sse2=1"

	# Use system-provided libraries.
	# TODO: use_system_ffmpeg (http://crbug.com/50678).
	# TODO: use_system_sqlite (http://crbug.com/22208).
	# TODO: use_system_hunspell (upstream changes needed).
	# TODO: use_system_ssl when we have a recent enough system NSS.
	myconf+="
		-Duse_system_bzip2=1
		-Duse_system_icu=1
		-Duse_system_libevent=1
		-Duse_system_libjpeg=1
		-Duse_system_libpng=1
		-Duse_system_libxml=1
		-Duse_system_zlib=1"

	# The dependency on cups is optional, see bug #324105.
	if use cups; then
		myconf+=" -Duse_cups=1"
	else
		myconf+=" -Duse_cups=0"
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

	# Disable the V8 snapshot. It breaks the build on hardened (bug #301880),
	# and the performance gain isn't worth it.
	myconf+=" -Dv8_use_snapshot=0"

	# Disable tcmalloc memory allocator. It causes problems,
	# for example bug #320419.
	myconf+=" -Dlinux_use_tcmalloc=0"

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

	if [[ "$(gcc-major-version)$(gcc-minor-version)" == "44" ]]; then
		myconf+=" -Dno_strict_aliasing=1 -Dgcc_version=44"
	fi

	# Work around a likely GCC bug, see bug #331945.
	if [[ "$(gcc-major-version)$(gcc-minor-version)" == "45" ]]; then
		append-flags -fno-ipa-cp
	fi

	# Make sure that -Werror doesn't get added to CFLAGS by the build system.
	# Depending on GCC version the warnings are different and we don't want
	# the build to fail because of that.
	myconf+=" -Dwerror="

	build/gyp_chromium -f make build/all.gyp ${myconf} --depth=. || die
}

src_compile() {
	emake -r V=1 chrome chrome_sandbox BUILDTYPE=Release \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		|| die
}

src_install() {
	exeinto "${CHROMIUM_HOME}"
	pax-mark m out/Release/chrome
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

	doexe out/Release/ffmpegsumo_nolink || die
	doexe out/Release/libffmpegsumo.so || die

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
