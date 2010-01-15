# Copyright 1999-2009 Sabayon Foundation
# Distributed under the terms of the GNU General Public License v2
#
EAPI="2"

inherit eutils autotools multilib python

FLASHLIBVER=6684

SRC_URI="http://dl.boxee.tv/${P}-source.tar.bz2
	 http://distfiles.sabayon.org/${CATEGORY}/xmbc-linux-tools-git20100110.tar.gz
	 http://dl.boxee.tv/flashlib-shared-${FLASHLIBVER}.tar.gz"
KEYWORDS="~x86 ~amd64"
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
	dev-lang/python"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	dev-util/cmake
	x86? ( dev-lang/nasm )
	>=app-emulation/emul-linux-x86-baselibs-20091231"

S=${WORKDIR}/${P}-source

MY_PREFIX=/opt/${PN}/
use x86 && MY_ARCH=i486
use amd64 && MY_ARCH=x86_64
PYTHON_INC="$(python_get_includedir)"

src_unpack() {
	unpack ${A}
	cd "${S}"

	einfo "Repacking Project Mayhem Webserver"
	cd web
	rm Project_Mayhem_III_webserver_v1.0.zip || die 'rm failed'
	cd Project\ Mayhem\ III/
	zip -r -9 -o ../Project_Mayhem_III_webserver_v1.0.zip ./* || die 'zip failed'

	cd "${S}"
	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf || die
	mv media/{S,s}plash.png || die
}

src_prepare() {
	# Fix the broken stuff
	for patch in `ls ${FILESDIR}/${PN}*.patch ${FILESDIR}/xbmc*.patch`; do
		epatch $patch
	done

	# Use upstream XMBC's working linux tools
	cp --no-dereference --preserve=all -R -v ${WORKDIR}/Linux ${S}/tools || die "XMBC Linux Tools copy Failed"

	# *Awesome* sed voodoo to fix Curl
	sed -i \
	-e 's:\(g_curlInterface.easy_setopt.*, \)\(NULL\):\1(void*)\2:g' \
		xbmc/FileSystem/FileCurl.cpp || die

	sed -i \
		-e 's: ftell64: dll_ftell64:' \
		xbmc/cores/DllLoader/exports/wrapper.c || die
	sed -i \
		-e '1i#include <stdlib.h>\n#include <string.h>\n' \
		xbmc/lib/libid3tag/libid3tag/metadata.c || die

	# some dirs ship generated autotools, some dont
	local d
	for d in . xbmc/cores/dvdplayer/Codecs/libbdnav xbmc/lib/libass; do
		[[ -d ${d} ]] || continue
		[[ -e ${d}/configure ]] && continue
		pushd ${d} >/dev/null
		einfo "Generating autotools in ${d}"
		eautoreconf
		popd >/dev/null
	done

	# Avoid lsb-release dependency
	sed -i \
		-e 's:/usr/bin/lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp

	# Do not use termcap #262822
	sed -i 's:-ltermcap::' xbmc/lib/libPython/Python/configure

	epatch_user #293109

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure

	# Prevent Mac OSX files being installed
	rm -rf system/python/lib-osx/

	# Use system Python
	cd xbmc/lib/libPython
	sed -i s#INCLUDES=#"INCLUDES=-I$PYTHON_INC "# Makefile || die "Setting system python failed"
	cd ${S}

	# change from xbmc to boxee
	sed -i 's/xbmc/boxee/g' ${S}/tools/Linux/xbmc.desktop || die "Desktop sed failed"
	sed -i 's/XBMC/Boxee/g' ${S}/tools/Linux/xbmc.desktop || die "Desktop sed failed"
	sed -i 's#boxee.png#/usr/share/pixmaps/boxee.png#g' \
					${S}/tools/Linux/xbmc.desktop || die "Desktop sed failed"

	# Create flashlib Makefile
	use amd64 && pic="-fPIC"
	cd "${WORKDIR}/flashlib-shared"
	epatch "${FILESDIR}/flashlib-Makefile.patch" || die "Patch failed"
	sed -e "s#@ARCH@#${MY_ARCH}#g" -i Makefile || die "sed failed."
	sed -e "s#@PIC@#${pic}#g" -i Makefile || die "sed failed."
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)

	econf \
		--prefix=${MY_PREFIX} \
		--disable-ccache \
		--disable-optimizations \
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
	cd "${WORKDIR}/flashlib-shared"
	emake || die "Make flashlib failed!"
	cp "${WORKDIR}/flashlib-shared/FlashLib-*-linux.so" "${S}/system/players/flashplayer"

	cd ${S}
	emake
	emake skins
	emake give_me_my_mouse_back
}

src_install() {
	# src_install is based on #191801.. thanks guys!
	insinto ${MY_PREFIX}/language
	doins -r language/*

	insinto ${MY_PREFIX}/media
	mv media/splash.png media/Splash.png
	doins	media/defaultrss.png \
		media/downloadrss.png \
		media/weather.rar \
		media/*.png
	doins -r media/boxee_screen_saver

	insinto ${MY_PREFIX}/media/Fonts
	doins media/Fonts/*.ttf

	insinto ${MY_PREFIX}/screensavers
	doins screensavers/*.xbs

	insinto ${MY_PREFIX}
	rm -f scripts/Lyrics/resources/skins/Boxee/720p
	rm -f scripts/Lyrics/resources/skins/Default/720p
	doins -r scripts
	dosym PAL ${MY_PREFIX}/scripts/Lyrics/resources/skins/Boxee/720p
	dosym PAL ${MY_PREFIX}/scripts/Lyrics/resources/skins/Default/720p

	insinto ${MY_PREFIX}/skin
	doins -r skin/boxee*

	exeinto ${MY_PREFIX}/system
	doexe system/*-${MY_ARCH}-linux.so
	insinto ${MY_PREFIX}/system
	doins -r system/scrapers
	doins -r system/keymaps

	for player in system/players/* ; do
		exeinto ${MY_PREFIX}/system/players/$(basename ${player})
		doexe ${player}/*-${MY_ARCH}-linux.so
	done

	exeinto ${MY_PREFIX}/system/python
	doexe system/python/*-${MY_ARCH}-linux.so

	insinto ${MY_PREFIX}/UserData
	cp -f UserData/sources.xml.in.diff.linux UserData/sources.xml
	cp -f UserData/advancedsettings.xml.in UserData/advancedsettings.xml
	doins UserData/*.xml
	doins
	dosym UserData ${MY_PREFIX}/userdata

	insinto ${MY_PREFIX}/system
	doins system/*.xml
	doins system/asound.conf
	doins -r system/scrapers

	insinto ${MY_PREFIX}/visualisations
	doins	visualisations/Goom.vis \
			visualisations/Waveform.vis \
			visualisations/opengl_spectrum.vis

	exeinto ${MY_PREFIX}/bin
	doexe bin-linux/boxee-rtorrent

	mv run-boxee-desktop.in run-boxee-desktop
	exeinto ${MY_PREFIX}
	doexe Boxee
	doexe run-boxee-desktop
	doexe give_me_my_mouse_back
	doexe xbmc-xrandr

	dodir /opt/bin
	dosym ${MY_PREFIX}/run-boxee-desktop /opt/bin/boxee

	# fix desktop files
	mv ${S}/tools/Linux/xbmc.desktop tools/Linux/boxee.desktop
	insinto /usr/share/applications
	doins tools/Linux/boxee.desktop
	# Fix icon
	cp media/icon.png tools/Linux/boxee.png
	insinto /usr/share/pixmaps
	doins tools/Linux/boxee.png

	dodir /etc/env.d
	echo "CONFIG_PROTECT=\"${MY_PREFIX}/UserData\"" > "${D}/etc/env.d/95boxee"

	# Evil closed source non 64bit flash player
	exeinto ${MY_PREFIX}/system/players/flashplayer
	doexe system/players/flashplayer/*linux* system/players/flashplayer/bxoverride.so
	insinto ${MY_PREFIX}/system/players/flashplayer
	doins -r system/players/flashplayer/boxeejs
	dodir xulrunner
	dosym /opt/xulrunner ${MY_PREFIX}/system/players/flashplayer/xulrunner/bin
	exeinto /opt/xulrunner/plugins
	doexe system/players/flashplayer/xulrunner-i486-linux/bin/plugins/libflashplayer.so
}
