# Copyright 1999-2009 Sabayon Foundation
# Distributed under the terms of the GNU General Public License v2
#
EAPI="2"

inherit eutils autotools multilib python

FLASHLIBVER=6684
MY_PREFIX=/opt/${PN}/
use x86 && MY_ARCH=i486
use amd64 && MY_ARCH=x86_64
PYTHON_INC="$(python_get_includedir)"

SRC_URI="http://dl.boxee.tv/${PN}-sources-${PV}.tar.bz2
	http://distfiles.sabayon.org/${CATEGORY}/xmbc-linux-tools-git20100110.tar.gz"
KEYWORDS="~amd64 ~x86"
DESCRIPTION="Cross-platform media center software based on XBMC"
HOMEPAGE="http://boxee.tv/"
LICENSE="GPL-2"
SLOT="0"
IUSE="+aac +alsa altivec +avahi +css debug joystick midi +opengl +pulseaudio +vdpau +xrandr"

RDEPEND="opengl? ( virtual/opengl )
	app-arch/bzip2
	|| ( app-arch/unrar app-arch/unrar-gpl )
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	>=dev-lang/python-2.4
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libcdio
	dev-libs/libpcre
	dev-libs/lzo
	>=dev-python/pysqlite-2
	media-libs/a52dec
	media-libs/alsa-lib
	aac? ( media-libs/faac )
	media-libs/faad2
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/jbigkit
	media-libs/jpeg
	>=media-libs/libass-0.9.7
	media-libs/libdca
	css? ( media-libs/libdvdcss )
	media-libs/libmad
	media-libs/libmms
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libsamplerate
	media-libs/libsdl[alsa,audio,video,X]
	media-libs/libvorbis
	media-libs/sdl-gfx
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	media-libs/tiff
	pulseaudio? ( media-sound/pulseaudio )
	media-sound/wavpack
	media-video/ffmpeg
	avahi? ( net-dns/avahi )
	net-misc/curl
	net-fs/samba
	sys-apps/dbus
	sys-apps/hal
	sys-libs/zlib
	virtual/mysql
	x11-apps/xdpyinfo
	x11-apps/mesa-progs
	vdpau? ( || ( x11-libs/libvdpau <x11-drivers/nvidia-drivers-185.18.36-r1 ) )
	x11-libs/libXinerama
	xrandr? ( x11-libs/libXrandr )
	x11-libs/libXrender
	dev-lang/python
	www-plugins/adobe-flash"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	dev-util/cmake
	x86? ( dev-lang/nasm )"

S=${WORKDIR}/${PN}-sources-${PV}

src_unpack() {
	unpack ${A}

	cd ${S}
	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf || die
	mv media/{S,s}plash.png || die
}

src_prepare() {
	# Fix the broken stuff
	for patch in `ls ${FILESDIR}/${PN}*.patch ${FILESDIR}/xbmc*.patch`; do
		epatch $patch
	done

	# Run autoconf
	eautoconf
	eautoreconf

	# sed voodoo to fix Curl
	sed -i \
	-e 's:\(g_curlInterface.easy_setopt.*, \)\(NULL\):\1(void*)\2:g' \
		xbmc/FileSystem/FileCurl.cpp || die

	sed -i \
		-e 's: ftell64: dll_ftell64:' \
		xbmc/cores/DllLoader/exports/wrapper.c || die
	sed -i \
		-e '1i#include <stdlib.h>\n#include <string.h>\n' \
		xbmc/lib/libid3tag/libid3tag/metadata.c || die

	# Add Destdir support to makefile
	sed -i 's#$(prefix)#$(DESTDIR)$(prefix)#g' ${S}/Makefile.in \
		|| die "Makefile sed failed"

	# Use upstream XMBC's (working) linux tools
	cp --no-dereference --preserve=all -R ${WORKDIR}/Linux ${S}/tools || die "XMBC Linux Tools copy Failed"

	# Use system Python
	sed -i s#INCLUDES=#"INCLUDES=-I$PYTHON_INC "# xbmc/lib/libPython/Makefile \
		|| die "Setting system python failed"

	# Avoid lsb-release dependency
	sed -i \
		-e 's:/usr/bin/lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp

	# Do not use termcap #262822
	sed -i 's:-ltermcap::' xbmc/lib/libPython/Python/configure

	epatch_user #293109

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure

	# Switch Desktop File
	sed 's/run-boxee-desktop/boxee/g' -i debian/boxee.desktop

	# Fix script paths
	for f in run-boxee-desktop.in run-boxee.in; do
		sed -i 's#BOXEE_PROC=Boxee#BOXEE_PROC=boxee#g' ${f} || die 'Sed Failed'
	done
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)

	econf \
		--prefix=${MY_PREFIX} \
		--disable-ccache \
		--enable-optimizations \
		--enable-external-libraries \
		--enable-goom \
		$(use_enable avahi) \
		$(use_enable css dvdcss) \
		$(use_enable debug) \
		$(use_enable aac faac) \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable opengl gl) \
		--disable-profiling \
		$(use_enable pulseaudio pulse) \
		$(use_enable vdpau) \
		$(use_enable xrandr)
}

src_compile() {
	emake
	emake skins
	emake give_me_my_mouse_back

	# Clean up Flashplayer cruft
	rm -rf ./xmbc/system/players/flashplayer/*osx*
	rm -rf ./xmbc/system/players/flashplayer/*win32*
}

src_install() {
	emake DESTDIR="${D}" install || die "Make install failed"

	# Menu
	doicon ${S}/debian/boxee.png
	domenu ${S}/debian/boxee.desktop

	dodir /opt/bin
	for i in boxee boxee-standalone; do
		dosym /opt/boxee/$i /opt/bin/$i
	done

	# Link flashplayer
	dodir ${MY_PREFIX}/share/system/players/flashplayer/xulrunner-${MY_ARCH}-linux/bin/plugins
	dosym /opt/netscape/plugins/libflashplayer.so \
		${MY_PREFIX}/share/system/players/flashplayer/xulrunner-${MY_ARCH}-linux/bin/plugins/libflashplayer.so
}

pkg_postinst() {
	echo
	ewarn ""
	ewarn "Please remove any previous configuration files from \
		~/.boxee before running this version"
	ewarn ""
	echo
	einfo ""
	einfo "This is still BETA software, crashes are to be expected"
	einfo ""
	einfo "Please see ${HOMEPAGE} to report issues and get support"
	einfo ""
	echo
}
