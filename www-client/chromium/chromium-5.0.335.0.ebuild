# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-5.0.335.0.ebuild,v 1.1 2010/02/25 09:06:18 phajdan.jr Exp $

EAPI="2"
inherit eutils flag-o-matic multilib portability toolchain-funcs

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
#SRC_URI="http://build.chromium.org/buildbot/archives/${P}.tar.bz2"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="+ffmpeg +plugins-symlink"

RDEPEND="app-arch/bzip2
	>=dev-libs/libevent-1.4.13
	dev-libs/libxml2
	dev-libs/libxslt
	>=dev-libs/nss-3.12.3
	>=gnome-base/gconf-2.24.0
	>=media-libs/alsa-lib-1.0.19
	media-libs/jpeg:0
	media-libs/libpng
	ffmpeg? ( >=media-video/ffmpeg-0.5_p19787 )
	sys-libs/zlib
	>=x11-libs/gtk+-2.14.7
	x11-libs/libXScrnSaver
	x11-misc/xdg-utils
	|| (
		x11-themes/gnome-icon-theme
		x11-themes/tango-icon-theme
		x11-themes/xfce4-icon-theme
	)"
#	dev-db/sqlite:3
DEPEND="${RDEPEND}
	>=dev-util/gperf-3.0.3
	>=dev-util/pkgconfig-0.23
	sys-devel/flex"

pkg_setup() {
	# Prevent user problems like bug 299777.
	if ! grep -q /dev/shm <<< $(get_mounts); then
		eerror "You don't have tmpfs mounted at /dev/shm."
		eerror "${PN} isn't going to work in that configuration."
		eerror "Please uncomment the /dev/shm entry in /etc/fstab,"
		eerror "run 'mount /dev/shm' and try again."
		die "/dev/shm is not mounted"
	fi
	if [ `stat -c %a /dev/shm` -ne 1777 ]; then
		eerror "/dev/shm does not have correct permissions."
		eerror "${PN} isn't going to work in that configuration."
		eerror "Please run chmod 1777 /dev/shm and try again."
		die "/dev/shm has incorrect permissions"
	fi

	elog "${PN} might crash occasionally. To get more useful backtraces"
	elog "and submit better bug reports, please read"
	elog "http://www.gentoo.org/proj/en/qa/backtraces.xml"
}

src_prepare() {
	# Gentoo uses .kde4, not .kde
	# TODO: this does not work with kdeprefix, fixing http:/crbug.com/29927
	# would be better
	sed -e 's/\.kde/.kde4/' -i net/proxy/proxy_config_service_linux.cc \
		|| die "kde proxy sed failed"
	# Changing this in ~/include.gypi does not work
	sed -i "s/'-Werror'/''/" build/common.gypi || die "Werror sed failed"
	# Prevent automatic -march=pentium4 -msse2 enabling on x86, http://crbug.com/9007
	epatch "${FILESDIR}"/${PN}-drop_sse2.patch
	# Allow use of MP3/MPEG-4 audio/video tags with our system ffmpeg
	epatch "${FILESDIR}"/${PN}-20100122-ubuntu-html5-video-mimetypes.patch
	# Add Sabayon User Agent to browser string
	epatch "${FILESDIR}"/${PN}-sabayon-user-agent.patch
	# Prevent the make build from filling entire disk space on some systems,
	# bug 297273.
	epatch "${FILESDIR}"/${PN}-fix-make-build.patch

	# Disable prefixing to allow linking against system zlib
	sed -e '/^#include "mozzconf.h"$/d' \
		-i third_party/zlib/zconf.h \
		|| die "zlib sed failed"
}

src_configure() {
	export CHROMIUM_HOME=/usr/$(get_libdir)/chromium-browser

	# Fails to build on arm if we don't do this
	use arm && append-flags -fno-tree-sink

	# CFLAGS/LDFLAGS
	mkdir -p "${S}"/.gyp
	cat << EOF > "${S}"/.gyp/include.gypi
{
	'target_defaults': {
		'cflags': [ '${CFLAGS// /','}' ],
		'ldflags': [ '${LDFLAGS// /','}' ],
	},
}
EOF
	export HOME="${S}"

	# Configuration options (system libraries)
	local myconf="-Duse_system_zlib=1 -Duse_system_bzip2=1 -Duse_system_libevent=1 -Duse_system_libjpeg=1 -Duse_system_libpng=1 -Duse_system_libxml=1 -Duse_system_libxslt=1 -Duse_system_ffmpeg=1"
	# -Duse_system_sqlite=1 : http://crbug.com/22208
	# Others still bundled: icu (not possible?), hunspell (changes required for sandbox support)

	# Sandbox paths
	myconf="${myconf} -Dlinux_sandbox_path=${CHROMIUM_HOME}/chrome_sandbox -Dlinux_sandbox_chrome_path=${CHROMIUM_HOME}/chrome"

	if use amd64 ; then
		myconf="${myconf} -Dtarget_arch=x64"
	fi

	if use x86 ; then
		myconf="${myconf} -Dtarget_arch=ia32"
	fi

	if use arm; then
		myconf="${myconf} -Dtarget_arch=arm -Ddisable_nacl=1 -Dlinux_use_tcmalloc=0"
	fi

	if [[ "$(gcc-major-version)$(gcc-minor-version)" == "44" ]]; then
		myconf="${myconf} -Dno_strict_aliasing=1 -Dgcc_version=44"
	fi

	build/gyp_chromium -f make build/all.gyp ${myconf} --depth=. || die "gyp failed"
}

src_compile() {
	emake -r V=1 chrome chrome_sandbox BUILDTYPE=Release \
		rootdir="${S}" \
		CC=$(tc-getCC) \
		CXX=$(tc-getCXX) \
		AR=$(tc-getAR) \
		RANLIB=$(tc-getRANLIB) \
		|| die "compilation failed"
}

src_install() {
	# Chromium does not have "install" target in the build system.
	export CHROMIUM_HOME=/usr/$(get_libdir)/chromium-browser

	dodir ${CHROMIUM_HOME}

	exeinto ${CHROMIUM_HOME}
	doexe out/Release/chrome
	doexe out/Release/chrome_sandbox
	fperms 4755 ${CHROMIUM_HOME}/chrome_sandbox
	doexe out/Release/xdg-settings
	doexe "${FILESDIR}"/chromium-launcher.sh

	insinto ${CHROMIUM_HOME}
	doins out/Release/chrome.pak

	doins -r out/Release/locales
	doins -r out/Release/resources

	# chrome.1 is for chromium --help
	newman out/Release/chrome.1 chrome.1
	newman out/Release/chrome.1 chromium.1

	if use ffmpeg; then
		# Chromium looks for these in its folder
		# See media_posix.cc and base_paths_linux.cc
		dosym /usr/$(get_libdir)/libavcodec.so.52 ${CHROMIUM_HOME}
		dosym /usr/$(get_libdir)/libavformat.so.52 ${CHROMIUM_HOME}
		dosym /usr/$(get_libdir)/libavutil.so.50 ${CHROMIUM_HOME}
	fi

	# Plugins symlink, optional wrt bug #301911
	if use plugins-symlink; then
		dosym /usr/$(get_libdir)/nsbrowser/plugins ${CHROMIUM_HOME}/plugins
	fi

	# Icon and desktop entry
	newicon out/Release/product_logo_48.png ${PN}-browser.png
	dosym ${CHROMIUM_HOME}/chromium-launcher.sh /usr/bin/chromium
	make_desktop_entry chromium "Chromium" ${PN}-browser "Network;WebBrowser"
	sed -e "/^Exec/s/$/ %U/" -i "${D}"/usr/share/applications/*.desktop \
		|| die "desktop file sed failed"
	# Gnome default application entry
	dodir /usr/share/gnome-control-center/default-apps
	insinto /usr/share/gnome-control-center/default-apps
	doins "${FILESDIR}"/chromium.xml

}
