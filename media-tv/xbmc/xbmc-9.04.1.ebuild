# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/xbmc/xbmc-9.04.1.ebuild,v 1.3 2009/09/26 12:11:40 vapier Exp $

# XXX: be nice to split out packages that come bundled and use the
#      system libraries ...

EAPI="2"

inherit eutils

# Use XBMC_ESVN_REPO_URI to track a different branch
ESVN_REPO_URI=${XBMC_ESVN_REPO_URI:-http://xbmc.svn.sourceforge.net/svnroot/xbmc/trunk}
ESVN_PROJECT=${ESVN_REPO_URI##*/svnroot/}
ESVN_PROJECT=${ESVN_PROJECT%/*}
if [[ ${PV} == "9999" ]] ; then
	inherit subversion
	KEYWORDS=""
else
	MY_P="${PV}_Babylon-linux-osx-win32"
	SRC_URI="mirror://sourceforge/${PN}/XBMC%20Source%20Code/Babylon%20-%209.04/${MY_P}-repack.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${MY_P}/XBMC
fi

DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa debug joystick opengl profile pulseaudio vdpau"

RDEPEND="opengl? ( virtual/opengl )
	app-arch/bzip2
	|| ( app-arch/unrar app-arch/unrar-gpl )
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	dev-db/sqlite:3
	>=dev-lang/python-2.4
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libcdio
	dev-libs/libpcre
	dev-libs/lzo
	>=dev-python/pysqlite-2
	media-libs/alsa-lib
	media-libs/faac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/libmad
	media-libs/libpng
	media-libs/libogg
	media-libs/libsamplerate
	media-libs/libsdl[alsa,audio,video,X]
	media-libs/libvorbis
	media-libs/sdl-gfx
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	media-libs/tiff
	media-sound/pulseaudio
	net-misc/curl
	sys-apps/dbus
	sys-apps/hal
	sys-apps/pmount
	virtual/mysql
	x11-apps/xdpyinfo
	x11-apps/mesa-progs
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	dev-util/cmake
	x86? ( dev-lang/nasm )"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		subversion_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-9.04-gcc.patch
	# Add jpeg-7 support
	epatch "${FILESDIR}"/xbmc-external-jbig-tiff.diff

	# Avoid help2man
	sed -i \
		-e '/HELP2MAN.*--output/s:.*:\ttouch $@:' \
		xbmc/lib/libcdio/libcdio/src/Makefile.in

	# Tweak autotool timestamps to avoid regeneration
	find . '(' -name configure -o -name configure2 -o -name '*.pl' ')' -exec chmod a+rx {} +
	find . -type f -exec touch -r configure {} +

	# Fix XBMC's final version string showing as "exported"
	# instead of the SVN revision number.  Also cleanup flags.
	export SVN_REV=${ESVN_WC_REVISION:-exported}
	sed -i -r -e '/DEBUG_FLAGS/s:-(g|O2)::' configure
	sed -i -e 's:\<strip\>:echo:' xbmc/lib/libhdhomerun/Makefile.in
	# Avoid lsb-release dependency
	sed -i \
		-e 's:/usr/bin/lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp

	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf
	mv media/{S,s}plash.png

	# Do not use termcap #262822
	sed -i 's:-ltermcap::' xbmc/lib/libPython/Python/configure

	# Unzip web content
	cd web
	unpack ./Project_Mayhem_III_webserver_*.zip
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no

	econf \
		--disable-ccache \
		--disable-optimizations \
		$(use_enable debug) \
		$(use_enable joystick) \
		$(use_enable opengl gl) \
		$(use_enable profile profiling) \
		$(use_enable pulseaudio pulse) \
		$(use_enable vdpau)
}

src_install() {
	einstall || die "Install failed!"

	insinto /usr/share/applications
	doins tools/Linux/xbmc.desktop
	doicon tools/Linux/xbmc.png

	dodoc README.linux known_issues.txt
	rm "${D}"/usr/share/xbmc/{README.linux,LICENSE.GPL,*.txt}
}

pkg_postinst() {
	elog "Visit http://xbmc.org/wiki/?title=XBMC_Online_Manual"
}
